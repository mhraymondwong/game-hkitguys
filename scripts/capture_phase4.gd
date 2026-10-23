extends SceneTree
## Capture title (with saves), hub (map btn), map → shots/07–09
## Usage: xvfb-run -a godot --path <project> --script res://scripts/capture_phase4.gd


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
		printerr("[phase4-shot] failed ", scene_path, " ", err)
		return false
	await process_frame
	await process_frame
	await process_frame
	await create_timer(0.7).timeout
	var img: Image = root.get_viewport().get_texture().get_image()
	if img == null:
		printerr("[phase4-shot] no image for ", out_rel)
		return false
	var out := ProjectSettings.globalize_path(out_rel)
	img.save_png(out)
	print("[phase4-shot] ", out, " ", img.get_width(), "x", img.get_height())
	return true


func _run() -> void:
	var gs := _ensure_gs()
	SaveSystem.clear_all_for_tests()
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.prepare_next_month()
	gs.apply_activity("feature-sprint", false)
	SaveSystem.save_slot(1, gs)
	gs.month = 7
	gs.year = 1
	SaveSystem.save_slot(2, gs)

	if not await _shot("res://scenes/title.tscn", "res://shots/07_title_load.png"):
		quit(1)
		return

	# Hub with map button visible
	SaveSystem.load_slot(1, gs)
	gs.month = 7
	gs.year = 1
	gs.map_used_this_month = false
	if not await _shot("res://scenes/hub.tscn", "res://shots/08_hub_map.png"):
		quit(1)
		return

	if not await _shot("res://scenes/map.tscn", "res://shots/09_map.png"):
		quit(1)
		return

	# Optional: map after visit
	gs.apply_map_visit("company")
	if not await _shot("res://scenes/map.tscn", "res://shots/09b_map_result.png"):
		quit(1)
		return

	SaveSystem.clear_all_for_tests()
	print("[phase4-shot] OK")
	quit(0)
