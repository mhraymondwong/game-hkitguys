extends SceneTree
## Capture cinematic full-art hub + month_resolve on sunset default.
## Usage: xvfb-run -a godot --path <project> --script res://scripts/capture_cinematic.gd


func _init() -> void:
	call_deferred("_run")


func _ensure_gs() -> Node:
	var gs: Node = root.get_node_or_null("GameState")
	if gs == null:
		var script: GDScript = load("res://scripts/game_state.gd") as GDScript
		gs = script.new()
		gs.name = "GameState"
		root.add_child(gs)
	return gs


func _shot(scene_path: String, out_rel: String) -> bool:
	var err := change_scene_to_file(scene_path)
	if err != OK:
		printerr("[cine-shot] failed ", scene_path, " ", err)
		return false
	await process_frame
	await process_frame
	await process_frame
	await create_timer(0.7).timeout
	var img: Image = root.get_viewport().get_texture().get_image()
	if img == null:
		printerr("[cine-shot] no image for ", out_rel)
		return false
	var out := ProjectSettings.globalize_path(out_rel)
	img.save_png(out)
	print("[cine-shot] ", out, " ", img.get_width(), "x", img.get_height(), " bg=", SceneBg.path_for(_ensure_gs()))
	return true


func _run() -> void:
	var gs := _ensure_gs()
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.job_level = "junior"
	gs.last_activity_id = "feature-sprint"
	gs.month = 4
	gs.year = 1
	print("[cine-shot] month_result bg=", SceneBg.path_for(gs, SceneBg.FALLBACK_MONTH))
	if not await _shot("res://scenes/month_result.tscn", "res://shots/19_cutout_cinematic_month_result.png"):
		quit(1)
		return

	gs.prepare_next_month()
	gs.job_level = "junior"
	gs.last_activity_id = "feature-sprint"
	gs.month = 4
	print("[cine-shot] hub bg=", SceneBg.path_for(gs, SceneBg.FALLBACK_HUB))
	if not await _shot("res://scenes/hub.tscn", "res://shots/17_cutout_cinematic_hub.png"):
		quit(1)
		return

	gs.apply_activity("upward-chat", false)
	gs.job_level = "junior"
	print("[cine-shot] resolve bg=", SceneBg.path_for(gs, SceneBg.FALLBACK_MONTH))
	if not await _shot("res://scenes/month_resolve.tscn", "res://shots/18_cutout_cinematic_month_resolve.png"):
		quit(1)
		return

	print("[cine-shot] OK")
	quit(0)
