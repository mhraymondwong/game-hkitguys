extends Control
## 月結算 — E glass；活動＋事件＋公司／市況／裁員危機／職涯 → 下個月


func _ready() -> void:
	if GameState.job_id == "" or GameState.last_activity_id == "":
		get_tree().change_scene_to_file("res://scenes/title.tscn")
		return
	SceneBg.apply_to(self, GameState, SceneBg.FALLBACK_MONTH)
	_build_ui()


func _build_ui() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 56)
	margin.add_theme_constant_override("margin_right", 56)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	add_child(margin)

	var card := UiStyle.make_card_panel()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(card)

	var main_row := HBoxContainer.new()
	main_row.add_theme_constant_override("separation", 22)
	card.add_child(main_row)

	var art_path := ProtagonistArt.fullbody_path(GameState)
	var art := UiStyle.make_art_frame(art_path, Vector2(158, 380), true)
	main_row.add_child(art)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_row.add_child(v)

	v.add_child(UiStyle.make_step_tag("月結 · %s" % GameState.season_label()))

	var h := Label.new()
	h.text = "%s　·　%s" % [GameState.calendar_label(), GameState.last_activity_title]
	h.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(h, 22)
	v.add_child(h)

	var delta_lbl := Label.new()
	delta_lbl.text = "活動變化：%s" % ActivitiesData.format_deltas(GameState.last_deltas)
	UiStyle.apply_label(delta_lbl, 14)
	delta_lbl.add_theme_color_override("font_color", GameConfig.COL_RIM_GOLD)
	v.add_child(delta_lbl)

	var flavour_panel := UiStyle.make_flavour_panel()
	flavour_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(flavour_panel)

	var flavour := Label.new()
	flavour.text = GameState.last_month_flavour
	flavour.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	flavour.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UiStyle.apply_label(flavour, 14)
	flavour_panel.add_child(flavour)

	if GameState.last_career_kind != "":
		v.add_child(UiStyle.make_step_tag("職涯　·　%s" % GameState.last_career_title))
		if GameState.last_career_flavour != "" and GameState.last_career_flavour != GameState.last_month_flavour:
			var c_panel := UiStyle.make_flavour_panel()
			v.add_child(c_panel)
			var c_fl := Label.new()
			c_fl.text = GameState.last_career_flavour
			c_fl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			UiStyle.apply_label(c_fl, 13)
			c_panel.add_child(c_fl)

	if GameState.last_company_changed or GameState.last_company_flavour != "":
		var co_tag := Label.new()
		var co_title := "公司動態　·　%s" % GameState.company_state_label()
		if GameState.last_company_changed:
			co_title += "（有變）"
		co_tag.text = co_title
		UiStyle.apply_label(co_tag, 14)
		co_tag.add_theme_color_override("font_color", GameConfig.COL_RIM_CYAN)
		v.add_child(co_tag)
		var co_panel := UiStyle.make_flavour_panel()
		v.add_child(co_panel)
		var co_fl := Label.new()
		co_fl.text = GameState.last_company_flavour
		co_fl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UiStyle.apply_label(co_fl, 13)
		co_panel.add_child(co_fl)

	if GameState.last_climate_flavour != "":
		var cl_title := "勞動市場　·　%s" % GameState.climate_label()
		if GameState.last_climate_changed:
			cl_title += "（有變）"
		v.add_child(UiStyle.make_step_tag(cl_title))
		var cl_panel := UiStyle.make_flavour_panel()
		v.add_child(cl_panel)
		var cl_fl := Label.new()
		cl_fl.text = GameState.last_climate_flavour
		cl_fl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UiStyle.apply_label(cl_fl, 13)
		cl_panel.add_child(cl_fl)

	if GameState.last_crisis_kind != "":
		var cr_tag := Label.new()
		cr_tag.text = "裁員／危機　·　%s" % GameState.last_crisis_title
		UiStyle.apply_label(cr_tag, 14)
		cr_tag.add_theme_color_override("font_color", Color(1.0, 0.45, 0.4))
		v.add_child(cr_tag)
		var cr_panel := UiStyle.make_flavour_panel()
		v.add_child(cr_panel)
		var cr_fl := Label.new()
		cr_fl.text = GameState.last_crisis_flavour
		cr_fl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UiStyle.apply_label(cr_fl, 13)
		cr_panel.add_child(cr_fl)

	if GameState.last_event_id != "":
		var ev_tag := Label.new()
		ev_tag.text = "本月插曲 · %s" % GameState.last_event_title
		UiStyle.apply_label(ev_tag, 14)
		ev_tag.add_theme_color_override("font_color", GameConfig.COL_RIM_CYAN)
		v.add_child(ev_tag)

		var ev_delta := Label.new()
		ev_delta.text = "事件變化：%s" % ActivitiesData.format_deltas(GameState.last_event_deltas)
		UiStyle.apply_label(ev_delta, 13, true)
		v.add_child(ev_delta)

		var ev_panel := UiStyle.make_flavour_panel()
		v.add_child(ev_panel)
		var ev_fl := Label.new()
		ev_fl.text = GameState.last_event_flavour
		ev_fl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UiStyle.apply_label(ev_fl, 13)
		ev_panel.add_child(ev_fl)

	var meta := Label.new()
	meta.text = "%s　｜　%s　｜　%s　｜　市況 %s　｜　%s　｜　績效 %d　｜　已過 %d 個月" % [
		GameState.job_title,
		GameState.company_name,
		GameState.company_state_label(),
		GameState.climate_label(),
		GameConfig.track_label(GameState.track),
		GameState.performance,
		GameState.months_played
	]
	meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(meta, 12, true)
	v.add_child(meta)

	var stats_head := Label.new()
	stats_head.text = "目前狀態"
	UiStyle.apply_label(stats_head, 13, true)
	stats_head.add_theme_color_override("font_color", GameConfig.COL_RIM_GOLD)
	v.add_child(stats_head)

	var stats_row := HBoxContainer.new()
	stats_row.add_theme_constant_override("separation", 10)
	v.add_child(stats_row)

	var vals := GameState.stats_dict()
	for k in ["infra", "app", "manage", "influence", "health"]:
		stats_row.add_child(
			UiStyle.make_stat_chip(GameConfig.stat_label(k), str(vals.get(k, 0)), GameConfig.bar_color(k))
		)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	v.add_child(row)

	var next_btn := Button.new()
	next_btn.text = "下個月"
	next_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.apply_button(next_btn, true)
	next_btn.pressed.connect(func() -> void:
		GameState.prepare_next_month()
		get_tree().change_scene_to_file("res://scenes/hub.tscn")
	)
	row.add_child(next_btn)

	var title_btn := Button.new()
	title_btn.text = "返回標題"
	UiStyle.apply_button(title_btn, false)
	title_btn.pressed.connect(func() -> void:
		GameState.begin_new_game()
		get_tree().change_scene_to_file("res://scenes/title.tscn")
	)
	row.add_child(title_btn)

	var tip := Label.new()
	tip.text = "一個月又過。繼續嚟，定休息吓先？"
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiStyle.apply_label(tip, 12, true)
	v.add_child(tip)
