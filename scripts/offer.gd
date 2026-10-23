extends Control
## 開局③：確認 Offer — E glass＋工卡


const PORTRAIT := "res://assets/protagonist/portrait_badge.jpg"


func _ready() -> void:
	if GameState.education_id == "" or GameState.job_id == "":
		get_tree().change_scene_to_file("res://scenes/job.tscn")
		return
	UiStyle.add_texture_background(self, "res://assets/job_bg.jpg")
	_build_ui()


func _build_ui() -> void:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var card := UiStyle.make_card_panel(Vector2(720, 0), true)
	center.add_child(card)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 16)
	card.add_child(outer)

	outer.add_child(UiStyle.make_step_tag("③／③　聘用"))

	var h := Label.new()
	h.text = "確認你嘅 Offer"
	UiStyle.apply_label(h, 30)
	outer.add_child(h)

	var lead := Label.new()
	lead.text = "簽之前再睇一眼——職位、公司、起薪同路線。接咗就係入行第一日。"
	lead.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(lead, 15, true)
	outer.add_child(lead)

	var work_shell := PanelContainer.new()
	work_shell.add_theme_stylebox_override(
		"panel",
		UiStyle.glass_style(GameConfig.COL_GLASS_SOFT, GameConfig.COL_RIM_GOLD, 16, true)
	)
	outer.add_child(work_shell)

	var work := HBoxContainer.new()
	work.add_theme_constant_override("separation", 22)
	work_shell.add_child(work)

	var badge := UiStyle.make_badge_panel(PORTRAIT, Vector2(132, 170), "準員工")
	work.add_child(badge)

	var summary_box := VBoxContainer.new()
	summary_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_box.add_theme_constant_override("separation", 12)
	work.add_child(summary_box)

	var edu_title := GameConfig.education_title(GameState.education_id)
	var track := GameConfig.track_label(GameState.track)
	var track_col := GameConfig.COL_INFRA if GameState.track == "infra" else GameConfig.COL_APP

	var job_lbl := Label.new()
	job_lbl.text = GameState.job_title
	UiStyle.apply_label(job_lbl, 26)
	summary_box.add_child(job_lbl)

	var track_chip := Label.new()
	track_chip.text = "路線　%s" % track
	UiStyle.apply_label(track_chip, 14, true)
	track_chip.add_theme_color_override("font_color", track_col)
	summary_box.add_child(track_chip)

	summary_box.add_child(_kv_row("公司", GameState.company_name))
	summary_box.add_child(_kv_row("建議起薪", "HK$%s／月" % GameState.salary, true))
	summary_box.add_child(_kv_row("學歷背景", edu_title))

	var path_lbl := Label.new()
	path_lbl.text = "%s　→　%s" % [edu_title, GameState.job_title]
	path_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(path_lbl, 13, true)
	path_lbl.add_theme_color_override("font_color", GameConfig.COL_RIM_GOLD)
	summary_box.add_child(path_lbl)

	var hint := Label.new()
	hint.text = "接約之後會進入第一個月——睇吓入職蜜月期點樣捱過。"
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(hint, 13, true)
	outer.add_child(hint)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	outer.add_child(row)

	var back := Button.new()
	back.text = "返回改職位"
	UiStyle.apply_button(back, false)
	back.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/job.tscn")
	)
	row.add_child(back)

	var accept := Button.new()
	accept.text = "接受聘用，上班去"
	accept.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.apply_button(accept, true)
	accept.pressed.connect(_on_accept)
	row.add_child(accept)


func _kv_row(key: String, value: String, emphasize: bool = false) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var k := Label.new()
	k.text = key
	k.custom_minimum_size = Vector2(96, 0)
	UiStyle.apply_label(k, 14, true)
	row.add_child(k)
	var val := Label.new()
	val.text = value
	val.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	val.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(val, 16)
	if emphasize:
		val.add_theme_color_override("font_color", GameConfig.COL_GOOD)
	row.add_child(val)
	return row


func _on_accept() -> void:
	if not GameState.accept_offer_and_run_first_month():
		return
	get_tree().change_scene_to_file("res://scenes/month_result.tscn")
