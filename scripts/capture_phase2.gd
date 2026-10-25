extends SceneTree
## Capture hub + month_resolve (+ refresh month_result) → shots/04–06
## Phase 3b: show distinct atmosphere BGs (junior / typhoon|overtime / lead)
## Usage: xvfb-run -a godot --path <project> --script res://scripts/capture_phase2.gd


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
		printerr("[phase2-shot] failed ", scene_path, " ", err)
		return false
	await process_frame
	await process_frame
	await process_frame
	await create_timer(0.7).timeout
	var img: Image = root.get_viewport().get_texture().get_image()
	if img == null:
		printerr("[phase2-shot] no image for ", out_rel)
		return false
	var out := ProjectSettings.globalize_path(out_rel)
	img.save_png(out)
	print("[phase2-shot] ", out, " ", img.get_width(), "x", img.get_height(), " bg=", SceneBg.path_for(_ensure_gs()))
	return true


func _select_first_activity(node: Node) -> void:
	for c in node.get_children():
		if c is Button:
			var t := str((c as Button).text)
			if t.begins_with("【") and "確認" not in t and "返回" not in t:
				(c as Button).pressed.emit()
				return
		_select_first_activity(c)


func _run() -> void:
	var gs := _ensure_gs()
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	# 04: cinematic sunset (junior default)
	gs.job_level = "junior"
	gs.last_activity_id = ""
	print("[phase2-shot] expect sunset bg=", SceneBg.path_for(gs, SceneBg.FALLBACK_MONTH))
	if not await _shot("res://scenes/month_result.tscn", "res://shots/04_month.png"):
		quit(1)
		return

	# 05 hub: summer + war-room → mood typhoon (priority 1)
	gs.prepare_next_month()
	gs.apply_activity("war-room", false)
	gs.prepare_next_month()
	gs.month = 7
	gs.year = 1
	gs.job_level = "junior"
	gs.last_activity_id = "war-room"
	print("[phase2-shot] expect typhoon bg=", SceneBg.path_for(gs, SceneBg.FALLBACK_HUB))

	var err := change_scene_to_file("res://scenes/hub.tscn")
	if err != OK:
		printerr("[phase2-shot] failed hub ", err)
		quit(1)
		return
	await process_frame
	await process_frame
	await process_frame
	var hub := root.get_child(root.get_child_count() - 1)
	_select_first_activity(hub)
	await process_frame
	await process_frame
	await create_timer(0.7).timeout
	var img: Image = root.get_viewport().get_texture().get_image()
	if img == null:
		printerr("[phase2-shot] no image for hub")
		quit(1)
		return
	var out := ProjectSettings.globalize_path("res://shots/05_hub.png")
	img.save_png(out)
	print("[phase2-shot] ", out, " ", img.get_width(), "x", img.get_height(), " bg=", SceneBg.path_for(gs, SceneBg.FALLBACK_HUB))

	# 06 resolve: lead meeting room (senior/lead stage)
	gs.month = 3
	gs.job_level = "lead"
	gs.last_activity_id = "upward-chat"
	gs.last_event_id = ""
	gs.last_event_title = ""
	gs.apply_activity("deep-rest", false)
	# Re-assert lead after apply (apply shouldn't change level for deep-rest)
	gs.job_level = "lead"
	gs.last_activity_id = "mentor-junior"
	print("[phase2-shot] expect lead bg=", SceneBg.path_for(gs, SceneBg.FALLBACK_MONTH))
	if not await _shot("res://scenes/month_resolve.tscn", "res://shots/06_month_resolve.png"):
		quit(1)
		return

	print("[phase2-shot] OK event=%s level=%s" % [gs.last_event_id, gs.job_level])
	quit(0)
