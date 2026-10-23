extends SceneTree
## Capture title / education / job / offer / month_result → shots/01–05
## Usage: xvfb-run -a godot --path <project> --script res://scripts/capture_opening.gd


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
		printerr("[opening-shot] failed ", scene_path, " ", err)
		return false
	await process_frame
	await process_frame
	await process_frame
	await create_timer(0.7).timeout
	var img: Image = root.get_viewport().get_texture().get_image()
	if img == null:
		printerr("[opening-shot] no image for ", out_rel)
		return false
	var out := ProjectSettings.globalize_path(out_rel)
	img.save_png(out)
	print("[opening-shot] ", out, " ", img.get_width(), "x", img.get_height())
	return true


func _run() -> void:
	var gs := _ensure_gs()
	gs.begin_new_game()

	if not await _shot("res://scenes/title.tscn", "res://shots/01_title.png"):
		quit(1)
		return

	if not await _shot("res://scenes/education.tscn", "res://shots/02_education.png"):
		quit(1)
		return

	gs.select_education("uni")
	if not await _shot("res://scenes/job.tscn", "res://shots/03_job.png"):
		quit(1)
		return

	gs.select_job("junior-dev")
	if not await _shot("res://scenes/offer.tscn", "res://shots/03b_offer.png"):
		quit(1)
		return

	gs.accept_offer_and_run_first_month()
	if not await _shot("res://scenes/month_result.tscn", "res://shots/04_month.png"):
		quit(1)
		return

	print("[opening-shot] OK")
	quit(0)
