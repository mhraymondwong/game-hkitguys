extends Control
## 第一個月結果 — cinematic full-art：左站立立繪＋右可捲敘事＋底 sticky CTA


func _ready() -> void:
	if GameState.job_id == "" or GameState.last_month_flavour == "":
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
	v.add_theme_constant_override("separation", 10)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(v)

	v.add_child(UiStyle.make_step_tag("入職滿月 · 公司已排 onboarding"))

	var h := Label.new()
	h.text = "入職第一個月：公司已替你排咗 onboarding／sprint"
	h.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(h, 20)
	v.add_child(h)

	var sub := Label.new()
	sub.text = "%s　·　呢個月唔使你揀——入職流程自動過完，下個月先開始自己排。" % GameState.job_title
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(sub, 13, true)
	sub.add_theme_color_override("font_color", GameConfig.COL_TAG_FG)
	v.add_child(sub)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(scroll)

	var scroll_body := VBoxContainer.new()
	scroll_body.add_theme_constant_override("separation", 10)
	scroll_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(scroll_body)

	var flavour_panel := UiStyle.make_flavour_panel()
	scroll_body.add_child(flavour_panel)
	var flavour := Label.new()
	flavour.text = GameState.last_month_flavour
	flavour.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
	UiStyle.apply_label(meta, 12, true)
	v.add_child(meta)

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

	var continue_btn := Button.new()
	continue_btn.text = "繼續打工"
	continue_btn.custom_minimum_size = Vector2(200, 54)
	UiStyle.apply_button(continue_btn, true)
	continue_btn.pressed.connect(func() -> void:
		GameState.prepare_next_month()
		get_tree().change_scene_to_file("res://scenes/hub.tscn")
	)
	row.add_child(continue_btn)
