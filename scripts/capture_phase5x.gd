extends SceneTree
## Capture hub (market climate / crisis) + month_resolve (layoff) → shots/12–13
## Usage: xvfb-run -a godot --path <project> --script res://scripts/capture_phase5x.gd


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
		printerr("[phase5x-shot] failed ", scene_path, " ", err)
		return false
	await process_frame
	await process_frame
	await process_frame
	await create_timer(0.7).timeout
	var img: Image = root.get_viewport().get_texture().get_image()
	if img == null:
		printerr("[phase5x-shot] no image for ", out_rel)
		return false
	var out := ProjectSettings.globalize_path(out_rel)
	img.save_png(out)
	print("[phase5x-shot] ", out, " ", img.get_width(), "x", img.get_height())
	return true


func _run() -> void:
	var gs := _ensure_gs()
	SaveSystem.clear_all_for_tests()

	# Hub with freezing climate + company shrinking (pre-crisis chrome)
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.prepare_next_month()
	gs.company_state = "shrinking"
	gs.market_climate = "freezing"
	gs.last_climate_flavour = LaborMarketData.resolve_flavour("freezing")
	gs.last_climate_changed = true
	gs.performance = 42
	gs.tenure_months = 14
	gs.month = 1
	gs.year = 2
	gs.hunt_progress = 25
	gs.forced_job_hunt = false
	gs.crisis_active = false
	gs.last_activity_id = "update-cv"
	gs.job_level = "mid"

	if not await _shot("res://scenes/hub.tscn", "res://shots/12_hub_market.png"):
		quit(1)
		return

	# Crisis hub lock
	gs.crisis_active = true
	gs.crisis_kind = "severance"
	gs.company_state = "shrinking"
	gs.market_climate = "freezing"
	gs.month = 2
	if not await _shot("res://scenes/hub.tscn", "res://shots/12b_hub_crisis.png"):
		quit(1)
		return

	# Resolve after crisis choice
	gs.apply_activity("crisis-severance", false)
	if gs.last_crisis_kind == "":
		gs.last_crisis_kind = "crisis-severance"
		gs.last_crisis_title = "危機抉擇・接受遣散"
		gs.last_crisis_flavour = "示範：接受遣散截圖。"
	gs.last_climate_flavour = LaborMarketData.resolve_flavour(gs.market_climate)
	gs.last_company_flavour = CompaniesData.state_flavour(gs.company_state)
	if not await _shot("res://scenes/month_resolve.tscn", "res://shots/13_resolve_layoff.png"):
		quit(1)
		return

	SaveSystem.clear_all_for_tests()
	print("[phase5x-shot] OK")
	quit(0)
