extends Control
## 月計劃 Hub — E glass；季節活動格＋存檔＋地圖＋公司／職涯／市況／危機（Phase 5.x）


var _list: VBoxContainer
var _confirm: Button
var _selected: String = ""
var _hint: Label
var _save_row: HBoxContainer
var _save_status: Label


func _ready() -> void:
	if GameState.job_id == "" or GameState.months_played < 1:
		get_tree().change_scene_to_file("res://scenes/title.tscn")
		return
	SceneBg.apply_to(self, GameState, SceneBg.FALLBACK_HUB)
	_build_ui()
	_refresh_list()
	_refresh_save_row()


func _build_ui() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var root_v := VBoxContainer.new()
	root_v.add_theme_constant_override("separation", 10)
	root_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_v.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(root_v)

	var line1 := "%s　｜　%s　·　%s" % [
		GameState.calendar_label(),
		GameState.job_title,
		GameState.job_level_label()
	]
	var line2 := "%s　｜　%s　｜　市況 %s　｜　%s　｜　績效 %d　｜　年資 %d 月　｜　HK$%s／月" % [
		GameState.company_name,
		GameState.company_state_label(),
		GameState.climate_label(),
		GameConfig.track_label(GameState.track),
		GameState.performance,
		GameState.tenure_months,
		GameState.salary
	]
	root_v.add_child(UiStyle.make_chrome_header(line1, line2))

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 18)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_v.add_child(body)

	var portrait := ProtagonistArt.portrait_path(GameState)
	var ring := UiStyle.make_stat_ring_portrait(portrait, GameState.stats_dict(), Vector2(300, 380))
	body.add_child(ring)

	var right := PanelContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_theme_stylebox_override(
		"panel",
		UiStyle.glass_style(GameConfig.COL_GLASS_STRONG, GameConfig.COL_RIM_CYAN, 20, true)
	)
	body.add_child(right)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	v.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(v)

	var step_txt := "本月計劃 · %s" % GameState.season_label()
	if GameState.is_crisis_month():
		step_txt = "危機月 · %s" % GameState.season_label()
	v.add_child(UiStyle.make_step_tag(step_txt))

	var h := Label.new()
	h.text = "危機抉擇——呢個月冇普通日常" if GameState.is_crisis_month() else "呢個月要點過？"
	UiStyle.apply_label(h, 22)
	v.add_child(h)

	var climate_lbl := Label.new()
	climate_lbl.text = "市況「%s」：%s" % [GameState.climate_label(), GameState.climate_hub_line()]
	climate_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(climate_lbl, 12, true)
	climate_lbl.add_theme_color_override("font_color", GameConfig.COL_RIM_CYAN)
	v.add_child(climate_lbl)

	var lead := Label.new()
	var offer_note := ""
	if GameState.is_crisis_month():
		offer_note = "　·　%s" % (
			LaborMarketData.crisis_title(GameState.crisis_kind) if GameState.crisis_kind != "" else "裁員／執笠壓力"
		)
	elif GameState.has_pending_offer():
		offer_note = "　·　有外部 Offer 待決定"
	elif GameState.can_push_promo():
		offer_note = "　·　可爭取升職／加薪"
	if GameState.is_crisis_month():
		lead.text = "公司「%s」。普通活動暫停——只可以揀危機應對。%s" % [
			GameState.company_state_label(),
			offer_note
		]
	else:
		lead.text = "每月專心一件大事。公司而家「%s」。亦可出街走地圖（每月一次）。%s" % [
			GameState.company_state_label(),
			offer_note
		]
	lead.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(lead, 13, true)
	v.add_child(lead)

	if GameState.hunt_progress > 0 or GameState.on_probation or GameState.forced_job_hunt:
		var meta := Label.new()
		var bits: PackedStringArray = []
		if GameState.hunt_progress > 0:
			bits.append("求職進度 %d" % GameState.hunt_progress)
		if GameState.on_probation:
			bits.append("試用期剩 %d 月" % GameState.probation_months_left)
		if GameState.forced_job_hunt:
			bits.append("強制搵工")
		meta.text = "　｜　".join(bits)
		UiStyle.apply_label(meta, 12, true)
		meta.add_theme_color_override("font_color", GameConfig.COL_RIM_GOLD)
		v.add_child(meta)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 180)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(scroll)

	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 8)
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_list)

	_hint = Label.new()
	_hint.text = "揀一項活動，再確認。"
	UiStyle.apply_label(_hint, 13, true)
	v.add_child(_hint)

	_save_status = Label.new()
	_save_status.text = ""
	UiStyle.apply_label(_save_status, 12, true)
	v.add_child(_save_status)

	_save_row = HBoxContainer.new()
	_save_row.add_theme_constant_override("separation", 8)
	v.add_child(_save_row)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	root_v.add_child(row)

	var title_btn := Button.new()
	title_btn.text = "返回標題"
	UiStyle.apply_button(title_btn, false)
	title_btn.pressed.connect(func() -> void:
		GameState.begin_new_game()
		get_tree().change_scene_to_file("res://scenes/title.tscn")
	)
	row.add_child(title_btn)

	var map_btn := Button.new()
	map_btn.text = "城市／公司"
	UiStyle.apply_button(map_btn, false)
	if GameState.map_used_this_month:
		map_btn.text = "城市／公司（已用）"
	map_btn.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/map.tscn")
	)
	row.add_child(map_btn)

	_confirm = Button.new()
	_confirm.text = "確認本月活動"
	_confirm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.apply_button(_confirm, true)
	_confirm.disabled = true
	_confirm.pressed.connect(_on_confirm)
	row.add_child(_confirm)


func _refresh_save_row() -> void:
	for c in _save_row.get_children():
		c.queue_free()
	for i in range(1, SaveSystem.SLOT_COUNT + 1):
		var btn := Button.new()
		var exists := SaveSystem.slot_exists(i)
		btn.text = "存到槽 %d%s" % [i, "（覆寫）" if exists else ""]
		UiStyle.apply_button(btn, false)
		btn.custom_minimum_size = Vector2(0, 40)
		var slot_i := i
		btn.pressed.connect(func() -> void:
			if SaveSystem.save_slot(slot_i, GameState):
				_save_status.text = "已存到槽 %d。" % slot_i
				_refresh_save_row()
			else:
				_save_status.text = "存檔失敗。"
		)
		_save_row.add_child(btn)


func _hub_activities() -> Array:
	# Severe layoff month: only crisis trio
	if GameState.is_crisis_month():
		var crisis_out: Array = []
		for cid in LaborMarketData.CRISIS_ACTIVITY_IDS:
			var ca: Dictionary = ActivitiesData.get_activity(str(cid))
			if not ca.is_empty():
				crisis_out.append(ca)
		return crisis_out
	var acts: Array = ActivitiesData.activities_for_track_season(GameState.track, GameState.month)
	var out: Array = []
	var has_offer := GameState.has_pending_offer()
	var can_promo := GameState.can_push_promo()
	for a in acts:
		var id := str(a.get("id", ""))
		if id in LaborMarketData.CRISIS_ACTIVITY_IDS:
			continue
		if id == "accept-hop" or id == "decline-hop":
			if not has_offer:
				continue
		elif id == "push-promo" and not can_promo and not has_offer:
			# Still show when close? Hide unless eligible to reduce noise
			if GameState.performance < 50 or GameState.tenure_months < 3:
				continue
		elif id in ["update-cv", "job-apply", "interview-round"]:
			pass  # always available
		out.append(a)
	# Pin offer / promo to top when relevant
	var pinned: Array = []
	var rest: Array = []
	for a in out:
		var id2 := str(a.get("id", ""))
		if id2 in ["accept-hop", "decline-hop", "push-promo"] and (has_offer or can_promo or id2 == "push-promo"):
			pinned.append(a)
		else:
			rest.append(a)
	return pinned + rest


func _refresh_list() -> void:
	for c in _list.get_children():
		c.queue_free()
	var acts: Array = _hub_activities()
	for a in acts:
		var id := str(a.get("id", ""))
		var bias := str(a.get("bias", ""))
		var tag := ActivitiesData.bias_label(bias)
		var season_star := bool(a.get("season_boost", false))
		var track_star := bias == GameState.track
		var mark := ""
		if id in LaborMarketData.CRISIS_ACTIVITY_IDS:
			mark = " ◆危機"
		elif id == "push-promo" and GameState.can_push_promo():
			mark = " ◆可爭取"
		elif id in ["accept-hop", "decline-hop"]:
			mark = " ◆Offer"
		elif season_star and track_star:
			mark = " ★季"
		elif season_star:
			mark = " ★"
		elif track_star:
			mark = " ◆"
		var btn := Button.new()
		btn.text = "【%s】%s%s\n%s　｜　%s" % [
			tag,
			a.get("title", ""),
			mark,
			a.get("desc", ""),
			ActivitiesData.format_deltas(a.get("deltas", {}))
		]
		UiStyle.apply_choice_button(btn, id == _selected)
		btn.custom_minimum_size = Vector2(0, 66)
		var id_capture := id
		var title_capture := str(a.get("title", ""))
		btn.pressed.connect(func() -> void:
			_selected = id_capture
			_confirm.disabled = false
			_hint.text = "已揀：%s" % title_capture
			_refresh_list()
		)
		_list.add_child(btn)


func _on_confirm() -> void:
	if _selected == "":
		return
	if not GameState.apply_activity(_selected):
		_hint.text = "活動套用失敗，請再試。"
		return
	get_tree().change_scene_to_file("res://scenes/month_resolve.tscn")
