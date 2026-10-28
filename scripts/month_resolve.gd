extends Control
## 月結算 — cinematic full-art：左站立立繪＋右可捲敘事＋底 sticky CTA


func _ready() -> void:
	if GameState.job_id == "" or GameState.last_activity_id == "":
		get_tree().change_scene_to_file("res://scenes/title.tscn")
		return
	SceneBg.apply_to(self, GameState, SceneBg.FALLBACK_MONTH)
	_build_ui()


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

	var stage_path := ProtagonistArt.cinematic_stage_path(GameState)
	var stage := UiStyle.make_cinematic_stat_stage(stage_path, GameState.stats_dict(), Vector2(460, 640))
	root_h.add_child(stage)

	var right_col := VBoxContainer.new()
	right_col.add_theme_constant_override("separation", 10)
	right_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_h.add_child(right_col)

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
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(v)

	var step_txt := "月結 · %s" % GameState.season_label()
	if GameState.last_probation_ended:
		step_txt = "月結 · 試用期完結"
	v.add_child(UiStyle.make_step_tag(step_txt))

	var h := Label.new()
	h.text = "%s　·　%s" % [GameState.calendar_label(), GameState.last_activity_title]
	h.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(h, 20)
	v.add_child(h)

	if GameState.last_probation_ended:
		var prob_banner := Label.new()
		prob_banner.text = "◆ 試用期過咗——正式員工"
		UiStyle.apply_label(prob_banner, 15)
		prob_banner.add_theme_color_override("font_color", GameConfig.COL_RIM_CYAN)
		v.add_child(prob_banner)
		var prob_fl := Label.new()
		prob_fl.text = "三個月倒數完咗。之後唔再顯示試用提醒——你可以當自己正式入冊。"
		prob_fl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UiStyle.apply_label(prob_fl, 12, true)
		v.add_child(prob_fl)

	var delta_lbl := Label.new()
	var delta_bits: PackedStringArray = []
	var act_d := ActivitiesData.format_deltas(GameState.last_deltas)
	if act_d != "" and act_d != "無明顯變化":
		delta_bits.append(act_d)
	elif act_d == "無明顯變化":
		delta_bits.append("屬性無明顯變化")
	var pd := int(GameState.last_performance_delta)
	if pd != 0:
		delta_bits.append("績效%s%d" % ["+" if pd > 0 else "", pd])
	else:
		delta_bits.append("績效 ±0")
	var sd := int(GameState.last_salary_delta)
	if sd != 0:
		delta_bits.append("人工 HK$%s→HK$%s（%s%d）" % [
			CompaniesData.format_salary(GameState.last_salary_before),
			GameState.salary,
			"+" if sd > 0 else "",
			sd
		])
	delta_lbl.text = "活動變化：%s" % "　｜　".join(delta_bits)
	delta_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(delta_lbl, 13)
	delta_lbl.add_theme_color_override("font_color", GameConfig.COL_RIM_GOLD)
	v.add_child(delta_lbl)

	if sd != 0:
		var raise_banner := Label.new()
		raise_banner.text = "◆ 人工變動：HK$%s → HK$%s" % [
			CompaniesData.format_salary(GameState.last_salary_before),
			GameState.salary
		]
		UiStyle.apply_label(raise_banner, 14)
		raise_banner.add_theme_color_override("font_color", GameConfig.COL_RIM_CYAN)
		v.add_child(raise_banner)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(scroll)

	var scroll_body := VBoxContainer.new()
	scroll_body.add_theme_constant_override("separation", 12)
	scroll_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(scroll_body)

	var flavour_panel := UiStyle.make_flavour_panel(true)
	scroll_body.add_child(flavour_panel)
	var flavour := Label.new()
	flavour.text = GameState.last_month_flavour
	flavour.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(flavour, 17)
	flavour_panel.add_child(flavour)

	if GameState.last_career_kind != "":
		scroll_body.add_child(UiStyle.make_step_tag("職涯　·　%s" % GameState.last_career_title))
		if GameState.last_career_flavour != "" and GameState.last_career_flavour != GameState.last_month_flavour:
			var c_panel := UiStyle.make_flavour_panel(true)
			scroll_body.add_child(c_panel)
			var c_fl := Label.new()
			c_fl.text = GameState.last_career_flavour
			c_fl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			UiStyle.apply_label(c_fl, 15)
			c_panel.add_child(c_fl)

	if GameState.last_company_changed:
		var co_tag := Label.new()
		co_tag.text = "公司動態　·　%s（有變）" % GameState.company_state_label()
		UiStyle.apply_label(co_tag, 14)
		co_tag.add_theme_color_override("font_color", GameConfig.COL_RIM_CYAN)
		scroll_body.add_child(co_tag)
		var co_panel := UiStyle.make_flavour_panel(true)
		scroll_body.add_child(co_panel)
		var co_fl := Label.new()
		co_fl.text = GameState.last_company_flavour
		co_fl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UiStyle.apply_label(co_fl, 15)
		co_panel.add_child(co_fl)
	elif GameState.company_state != "":
		# Unchanged → one short chip, no repeated essay
		var co_chip := Label.new()
		co_chip.text = CompaniesData.state_chip(GameState.company_state) + "（無變）"
		UiStyle.apply_label(co_chip, 12, true)
		co_chip.add_theme_color_override("font_color", GameConfig.COL_RIM_CYAN)
		scroll_body.add_child(co_chip)

	if GameState.last_climate_changed and GameState.last_climate_flavour != "":
		scroll_body.add_child(UiStyle.make_step_tag("勞動市場　·　%s（有變）" % GameState.climate_label()))
		var cl_panel := UiStyle.make_flavour_panel(true)
		scroll_body.add_child(cl_panel)
		var cl_fl := Label.new()
		cl_fl.text = GameState.last_climate_flavour
		cl_fl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UiStyle.apply_label(cl_fl, 15)
		cl_panel.add_child(cl_fl)
	elif GameState.market_climate != "":
		var cl_chip := Label.new()
		cl_chip.text = LaborMarketData.climate_chip(GameState.market_climate) + "（無變）"
		UiStyle.apply_label(cl_chip, 12, true)
		scroll_body.add_child(cl_chip)

	if GameState.last_crisis_kind != "":
		var cr_tag := Label.new()
		cr_tag.text = "裁員／危機　·　%s" % GameState.last_crisis_title
		UiStyle.apply_label(cr_tag, 14)
		cr_tag.add_theme_color_override("font_color", Color(1.0, 0.45, 0.4))
		scroll_body.add_child(cr_tag)
		var cr_panel := UiStyle.make_flavour_panel(true)
		scroll_body.add_child(cr_panel)
		var cr_fl := Label.new()
		cr_fl.text = GameState.last_crisis_flavour
		cr_fl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UiStyle.apply_label(cr_fl, 15)
		cr_panel.add_child(cr_fl)

	if GameState.last_event_id != "":
		var ev_tag := Label.new()
		ev_tag.text = "本月插曲 · %s" % GameState.last_event_title
		UiStyle.apply_label(ev_tag, 14)
		ev_tag.add_theme_color_override("font_color", GameConfig.COL_RIM_CYAN)
		scroll_body.add_child(ev_tag)

		var ev_delta := Label.new()
		ev_delta.text = "事件變化：%s" % ActivitiesData.format_deltas(GameState.last_event_deltas)
		UiStyle.apply_label(ev_delta, 13, true)
		scroll_body.add_child(ev_delta)

		var ev_panel := UiStyle.make_flavour_panel(true)
		scroll_body.add_child(ev_panel)
		var ev_fl := Label.new()
		ev_fl.text = GameState.last_event_flavour
		ev_fl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UiStyle.apply_label(ev_fl, 15)
		ev_panel.add_child(ev_fl)

	var meta := Label.new()
	var pd_show := GameState.last_performance_delta
	var pd_txt := ("+%d" % pd_show) if pd_show > 0 else str(pd_show)
	meta.text = "%s　｜　HK$%s／月　｜　%s　｜　%s　｜　市況 %s　｜　績效 %d（本月 %s）　｜　已過 %d 個月" % [
		GameState.job_title,
		GameState.salary,
		GameState.company_name,
		GameState.company_state_label(),
		GameState.climate_label(),
		GameState.performance,
		pd_txt,
		GameState.months_played
	]
	meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(meta, 11, true)
	v.add_child(meta)

	# Sticky bottom bar (outside right panel)
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

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)

	var next_btn := Button.new()
	next_btn.text = "下個月"
	next_btn.custom_minimum_size = Vector2(200, 54)
	UiStyle.apply_button(next_btn, true)
	next_btn.pressed.connect(func() -> void:
		GameState.prepare_next_month()
		get_tree().change_scene_to_file("res://scenes/hub.tscn")
	)
	row.add_child(next_btn)
