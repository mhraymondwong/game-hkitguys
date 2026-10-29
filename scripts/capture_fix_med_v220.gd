extends SceneTree
## Capture map PNG icons + salary-hold copy + Feature Sprint flavour rotate (v2.0.20).
## Usage: xvfb-run -a godot --path <project> --script res://scripts/capture_fix_med_v220.gd


const OUT_DIR := "res://shots/fix_med_v220"


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


func _shot(name: String) -> bool:
	await process_frame
	await process_frame
	await process_frame
	await create_timer(0.35).timeout
	var img: Image = root.get_viewport().get_texture().get_image()
	if img == null:
		printerr("[v220-shot] no image for ", name)
		return false
	var out := ProjectSettings.globalize_path("%s/%s" % [OUT_DIR, name])
	img.save_png(out)
	print("[v220-shot] ", out, " ", img.get_width(), "x", img.get_height())
	return true


func _run() -> void:
	var dir := DirAccess.open("res://shots")
	if dir:
		dir.make_dir_recursive("fix_med_v220")

	var gs := _ensure_gs()
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.prepare_next_month()
	# Keep map available
	gs.map_used_this_month = false

	# —— (a) Map icons ——
	var err := change_scene_to_file("res://scenes/map.tscn")
	if err != OK:
		printerr("[v220-shot] map scene failed ", err)
		quit(1)
		return
	await process_frame
	await process_frame
	await create_timer(0.5).timeout
	await _shot("01_map_icons_png.png")

	# —— (b) Salary hold on resolve after a work month ——
	gs = _ensure_gs()
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.prepare_next_month()
	gs.apply_activity("feature-sprint", true)
	err = change_scene_to_file("res://scenes/month_resolve.tscn")
	if err != OK:
		printerr("[v220-shot] resolve failed ", err)
		quit(1)
		return
	await process_frame
	await process_frame
	await create_timer(0.5).timeout
	await _shot("02_salary_hold_reason.png")
	print("[v220-shot] hold=", gs.last_salary_hold_reason)

	# —— (c) Feature Sprint second flavour ——
	# Capture by writing flavours to a side text panel via temporary labels is hard;
	# instead re-open resolve after second pick and also dump comparison PNG from hub...
	# We screenshot resolve story card for pick #2, and save a small overlay note file.
	var fl1: String = str(gs.last_month_flavour)
	gs.prepare_next_month()
	gs.apply_activity("feature-sprint", false)
	var fl2: String = str(gs.last_month_flavour)
	err = change_scene_to_file("res://scenes/month_resolve.tscn")
	if err != OK:
		printerr("[v220-shot] resolve2 failed ", err)
		quit(1)
		return
	await process_frame
	await process_frame
	await create_timer(0.5).timeout
	await _shot("03_feature_sprint_second_flavour.png")

	# Also first flavour reference: re-apply path with use_count 0 by reset
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.prepare_next_month()
	gs.apply_activity("feature-sprint", false)
	err = change_scene_to_file("res://scenes/month_resolve.tscn")
	if err != OK:
		quit(1)
		return
	await process_frame
	await process_frame
	await create_timer(0.5).timeout
	await _shot("03b_feature_sprint_first_flavour.png")

	var note_path := ProjectSettings.globalize_path("%s/flavour_compare.txt" % OUT_DIR)
	var f := FileAccess.open(note_path, FileAccess.WRITE)
	if f:
		f.store_string("first=%s\n\nsecond=%s\n\ndifferent=%s\n" % [fl1, fl2, str(fl1 != fl2)])
		f.close()
		print("[v220-shot] wrote ", note_path)
	print("[v220-shot] flavour different? ", fl1 != fl2)
	print("[v220-shot] DONE")
	quit(0)
