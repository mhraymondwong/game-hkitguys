extends SceneTree
## Capture hub (company state) + month_resolve (career) → shots/10–11
## Usage: xvfb-run -a godot --path <project> --script res://scripts/capture_phase5.gd


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
		printerr("[phase5-shot] failed ", scene_path, " ", err)
		return false
	await process_frame
	await process_frame
	await process_frame
	await create_timer(0.7).timeout
	var img: Image = root.get_viewport().get_texture().get_image()
	if img == null:
		printerr("[phase5-shot] no image for ", out_rel)
		return false
	var out := ProjectSettings.globalize_path(out_rel)
	img.save_png(out)
	print("[phase5-shot] ", out, " ", img.get_width(), "x", img.get_height())
	return true


func _run() -> void:
	var gs := _ensure_gs()
	SaveSystem.clear_all_for_tests()
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.prepare_next_month()
	gs.company_state = "expanding"
	gs.performance = 82
	gs.tenure_months = 10
	gs.month = 4
	gs.year = 1
	gs.last_company_flavour = CompaniesData.state_flavour("expanding")
	gs.last_company_changed = true
	gs.job_level = "manager"
	gs.last_activity_id = "upward-chat"
	gs.month = 4

	if not await _shot("res://scenes/hub.tscn", "res://shots/10_hub_company.png"):
		quit(1)
		return

	# Promotion result on resolve
	gs.job_level = "senior"
	gs.last_activity_id = "push-promo"
	gs.apply_activity("push-promo", false)
	# Ensure visible career block
	if gs.last_career_kind == "":
		gs.last_career_kind = "promo"
		gs.last_career_title = "升職成功"
		gs.last_career_flavour = "示範：升職成功截圖。"
	gs.last_company_changed = true
	gs.last_company_flavour = "公司動態：穩定 → 擴充中。"
	if not await _shot("res://scenes/month_resolve.tscn", "res://shots/11_resolve_career.png"):
		quit(1)
		return

	# Hop result
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.prepare_next_month()
	gs.hunt_progress = 90
	gs.influence = 45
	gs.app = 55
	gs.apply_activity("interview-round", false)
	if gs.has_pending_offer():
		gs.apply_activity("accept-hop", false)
	else:
		# synthesize
		gs.pending_offer = CompaniesData.generate_offer(gs.stats_dict(), gs.track, gs.job_level, gs.company_id, 12345)
		gs.pending_offer["salary_num"] = 28000
		gs.apply_activity("accept-hop", false)
	if not await _shot("res://scenes/month_resolve.tscn", "res://shots/11b_resolve_hop.png"):
		quit(1)
		return

	SaveSystem.clear_all_for_tests()
	print("[phase5-shot] OK")
	quit(0)
