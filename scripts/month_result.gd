extends Control
## 第一個月結果 — E glass；→ 繼續打工（Hub）／返回標題


func _ready() -> void:
	if GameState.job_id == "" or GameState.last_month_flavour == "":
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
	main_row.add_theme_constant_override("separation", 24)
	card.add_child(main_row)

	var art_path := ProtagonistArt.month_result_fullbody_path(GameState)
	var art := UiStyle.make_art_frame(art_path, Vector2(158, 380), true)
	main_row.add_child(art)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_row.add_child(v)

	v.add_child(UiStyle.make_step_tag("入職滿月"))

	var h := Label.new()
	h.text = "第一個月 · %s" % GameState.job_title
	h.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(h, 26)
	v.add_child(h)

	var flavour_panel := UiStyle.make_flavour_panel()
	flavour_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(flavour_panel)

	var flavour := Label.new()
	flavour.text = GameState.last_month_flavour
	flavour.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	flavour.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UiStyle.apply_label(flavour, 15)
	flavour_panel.add_child(flavour)

	var meta := Label.new()
	meta.text = "%s　｜　%s（%s）　｜　HK$%s／月　｜　%s" % [
		GameConfig.education_title(GameState.education_id),
		GameState.job_title,
		GameConfig.track_label(GameState.track),
		GameState.salary,
		GameState.company_name
	]
	meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(meta, 13, true)
	v.add_child(meta)

	var stats_head := Label.new()
	stats_head.text = "目前狀態"
	UiStyle.apply_label(stats_head, 14, true)
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

	var continue_btn := Button.new()
	continue_btn.text = "繼續打工"
	continue_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.apply_button(continue_btn, true)
	continue_btn.pressed.connect(func() -> void:
		GameState.prepare_next_month()
		get_tree().change_scene_to_file("res://scenes/hub.tscn")
	)
	row.add_child(continue_btn)

	var title_btn := Button.new()
	title_btn.text = "返回標題"
	UiStyle.apply_button(title_btn, false)
	title_btn.pressed.connect(func() -> void:
		GameState.begin_new_game()
		get_tree().change_scene_to_file("res://scenes/title.tscn")
	)
	row.add_child(title_btn)

	var tip := Label.new()
	tip.text = "蜜月期捱完。想繼續嘅話，下個月你話事。"
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiStyle.apply_label(tip, 12, true)
	v.add_child(tip)
