extends SceneTree
## Capture hub CTA full text + 5th activity card clear of sticky bar (v2.0.19).
## Usage: xvfb-run -a godot --path <project> --script res://scripts/capture_fix_high_v219.gd


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


func _shot(out_rel: String) -> bool:
	await process_frame
	await process_frame
	await process_frame
	await create_timer(0.35).timeout
	var img: Image = root.get_viewport().get_texture().get_image()
	if img == null:
		printerr("[v219-shot] no image for ", out_rel)
		return false
	var out := ProjectSettings.globalize_path(out_rel)
	img.save_png(out)
	print("[v219-shot] ", out, " ", img.get_width(), "x", img.get_height())
	return true


func _hub_node() -> Node:
	return root.get_child(root.get_child_count() - 1)


func _run() -> void:
	var gs := _ensure_gs()
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	# Advance toward mid-year hub with hoodie social vibe + many cards
	gs.prepare_next_month()
	gs.month = 5
	gs.year = 1
	gs.months_played = 5
	gs.tenure_months = 5
	gs.last_activity_id = "team-lunch"
	gs.map_used_this_month = true
	gs.last_climate_changed = false
	gs.last_company_changed = false

	var err := change_scene_to_file("res://scenes/hub.tscn")
	if err != OK:
		printerr("[v219-shot] hub scene failed ", err)
		quit(1)
		return
	await process_frame
	await process_frame
	await create_timer(0.5).timeout

	var hub: Node = _hub_node()
	if hub == null or not hub.has_method("_refresh_list"):
		printerr("[v219-shot] hub node missing")
		quit(1)
		return

	# Select first activity so confirm enables (full CTA text)
	var list: VBoxContainer = hub.get("_list")
	var scroll: ScrollContainer = hub.get("_scroll")
	var confirm: Button = hub.get("_confirm")
	if list == null or scroll == null or confirm == null:
		printerr("[v219-shot] missing list/scroll/confirm")
		quit(1)
		return

	var cards: Array = []
	for c in list.get_children():
		if c is Button:
			cards.append(c)
	if cards.is_empty():
		printerr("[v219-shot] no activity cards")
		quit(1)
		return

	# Click/select card 0 for CTA shot
	(cards[0] as Button).emit_signal("pressed")
	await process_frame
	await process_frame
	await create_timer(0.4).timeout
	if not await _shot("res://shots/fix_high_v219/01_confirm_cta_full.png"):
		quit(1)
		return

	# Re-fetch cards after refresh
	list = hub.get("_list")
	cards.clear()
	for c in list.get_children():
		if c is Button:
			cards.append(c)
	print("[v219-shot] card count=", cards.size())
	if cards.size() < 5:
		printerr("[v219-shot] need >=5 cards, got ", cards.size())
		quit(1)
		return

	# Select 5th card (index 4) — ensure_control_visible should clear sticky bar
	(cards[4] as Button).emit_signal("pressed")
	await process_frame
	await process_frame
	await create_timer(0.8).timeout
	list = hub.get("_list")
	scroll = hub.get("_scroll")
	cards.clear()
	for c in list.get_children():
		if c is Button:
			cards.append(c)
	var fifth: Button = cards[4] as Button
	var bar_node: Node = hub.find_child("StickyCtaBar", true, false)
	print("[v219-shot] fifth y=", fifth.global_position.y, " h=", fifth.size.y, " bottom=", fifth.global_position.y + fifth.size.y)
	if bar_node is Control:
		var bc := bar_node as Control
		print("[v219-shot] bar y=", bc.global_position.y, " gap=", bc.global_position.y - (fifth.global_position.y + fifth.size.y))
		if fifth.global_position.y + fifth.size.y > bc.global_position.y + 1.0:
			printerr("[v219-shot] FAIL: 5th card overlaps sticky bar")
			quit(1)
			return
		else:
			print("[v219-shot] 5th card clear of sticky bar OK")
	if not await _shot("res://shots/fix_high_v219/02_fifth_card_clear.png"):
		quit(1)
		return

	# Also scroll to absolute bottom to show last cards + pad
	scroll = hub.get("_scroll")
	if scroll:
		scroll.scroll_vertical = 99999
	await process_frame
	await create_timer(0.3).timeout
	if not await _shot("res://shots/fix_high_v219/03_scroll_bottom.png"):
		quit(1)
		return

	print("[v219-shot] OK confirm='", confirm.text, "' disabled=", confirm.disabled)
	quit(0)
