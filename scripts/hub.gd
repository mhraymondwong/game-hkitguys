extends Control
## 月計劃 Hub — cinematic full-art shell：左站立立繪＋右玻璃活動＋底 sticky CTA


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
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)

	# Left stage full-height (feet on floor); right = glass + sticky CTA
	var root_h := HBoxContainer.new()
	root_h.add_theme_constant_override("separation", 16)
	root_h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_h.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(root_h)

	# LEFT ~40%: cinematic standing stage (no glass card)
	var stage_path := ProtagonistArt.cinematic_stage_path(GameState)
	var stage := UiStyle.make_cinematic_stat_stage(stage_path, GameState.stats_dict(), Vector2(460, 640))
	root_h.add_child(stage)

	var right_col := VBoxContainer.new()
	right_col.add_theme_constant_override("separation", 10)
	right_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_h.add_child(right_col)

	# RIGHT ~55%: one large glass panel
	var right := PanelContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_theme_stylebox_override(
		"panel",
		UiStyle.glass_style(GameConfig.COL_GLASS_STRONG, GameConfig.COL_RIM_CYAN, 20, true)
	)
	right_col.add_child(right)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	v.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(v)

	# Slim status inside glass (not dense top chrome chips)
	var status := Label.new()
	status.text = "%s　｜　%s　·　%s　｜　HK$%s／月" % [
		GameState.calendar_label(),
		GameState.job_title,
		GameState.job_level_label(),
		GameState.salary
	]
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(status, 13, true)
	status.add_theme_color_override("font_color", GameConfig.COL_TAG_FG)
	v.add_child(status)

	var status2 := Label.new()
	status2.text = "%s　｜　%s　｜　市況 %s　｜　績效 %d　｜　年資 %d 月" % [
		GameState.company_name,
		GameState.company_state_label(),
		GameState.climate_label(),
		GameState.performance,
		GameState.tenure_months
	]
	status2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(status2, 11, true)
	v.add_child(status2)

	var step_txt := "本月計劃 · %s" % GameState.season_label()
	if GameState.is_crisis_month():
		step_txt = "危機月 · %s" % GameState.season_label()
	elif GameState.last_probation_ended:
		step_txt = "正式員工 · %s" % GameState.season_label()
	v.add_child(UiStyle.make_step_tag(step_txt))

	var h := Label.new()
	if GameState.is_crisis_month():
		h.text = "危機抉擇——呢個月冇普通日常"
	elif GameState.last_probation_ended:
		h.text = "試用期過咗——正式員工。呢個月要點過？"
	else:
		h.text = "呢個月要點過？"
	UiStyle.apply_label(h, 22)
	v.add_child(h)

	# Climate / company: full essay only when changed; else short chip (anti-spam)
	var climate_lbl := Label.new()
	if GameState.last_climate_changed:
		climate_lbl.text = "市況「%s」：%s" % [GameState.climate_label(), GameState.climate_hub_line()]
	else:
		climate_lbl.text = "%s　｜　%s" % [GameState.climate_hub_line(), GameState.company_hub_line()]
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
		lead.text = "普通活動暫停——只可以揀危機應對。%s" % offer_note
	elif GameState.last_company_changed:
		lead.text = "每月專心一件大事。%s　亦可出街走地圖（每月一次）。%s" % [
			GameState.company_hub_line(),
			offer_note
		]
	else:
		lead.text = "每月專心一件大事。亦可出街走地圖（每月一次）。%s" % offer_note
	lead.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(lead, 13, true)
	v.add_child(lead)

	if GameState.hunt_progress > 0 or GameState.on_probation or GameState.forced_job_hunt or GameState.last_probation_ended:
		var meta := Label.new()
		var bits: PackedStringArray = []
		if GameState.hunt_progress > 0:
			bits.append("求職進度 %d" % GameState.hunt_progress)
		if GameState.on_probation:
			bits.append("試用期剩 %d 月" % GameState.probation_months_left)
		elif GameState.last_probation_ended:
			bits.append("試用期過咗——正式員工")
		if GameState.forced_job_hunt:
			bits.append("強制搵工")
		meta.text = "　｜　".join(bits)
		UiStyle.apply_label(meta, 12, true)
		meta.add_theme_color_override("font_color", GameConfig.COL_TAG_FG)
		v.add_child(meta)

	# Consume probation-end one-shot after hub chrome rendered
	if GameState.last_probation_ended:
		GameState.last_probation_ended = false

	# Activity list: claim remaining glass height (hint/saves live in sticky bar → no clip)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 280)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	v.add_child(scroll)

	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 8)
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_list)

	_hint = Label.new()
	_hint.text = "揀一項活動，再確認。"
	UiStyle.apply_label(_hint, 12, true)

	_save_status = Label.new()
	_save_status.text = ""
	UiStyle.apply_label(_save_status, 11, true)

	_save_row = HBoxContainer.new()
	_save_row.add_theme_constant_override("separation", 6)

	# BOTTOM sticky CTA bar: title / map / compact saves / hint / confirm
	var bar := UiStyle.make_sticky_cta_bar()
	right_col.add_child(bar)
	var row: HBoxContainer = bar.get_node("Row")

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

	row.add_child(_save_row)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)

	var hint_col := VBoxContainer.new()
	hint_col.add_theme_constant_override("separation", 2)
	hint_col.add_child(_hint)
	hint_col.add_child(_save_status)
	row.add_child(hint_col)

	_confirm = Button.new()
	_confirm.text = "確認本月活動"
	_confirm.custom_minimum_size = Vector2(200, 50)
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
		btn.text = "存%d%s" % [i, "·" if exists else ""]
		UiStyle.apply_button(btn, false)
		btn.custom_minimum_size = Vector2(56, 40)
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
	# Soft options（團隊飯／茶餐廳／休息）唔好只藏地圖——非危機月浮上列表前段
	rest = ActivitiesData.ensure_social_rest_visible(rest, GameState.month, 6)
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
		var is_crisis := id in LaborMarketData.CRISIS_ACTIVITY_IDS
		var mark := ""
		if is_crisis:
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
		var tex := UiIcons.load_bias_icon(bias, is_crisis)
		if tex:
			btn.icon = tex
			btn.expand_icon = true
			btn.add_theme_constant_override("icon_max_width", 52)
		UiStyle.apply_choice_button(btn, id == _selected)
		btn.custom_minimum_size = Vector2(0, 68)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
