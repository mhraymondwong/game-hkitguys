extends Control
## 開局①：綜合畢業／大學畢業 — E glass


var _choices: VBoxContainer
var _next_btn: Button
var _selected: String = ""


func _ready() -> void:
	_selected = GameState.education_id
	UiStyle.add_texture_background(self, "res://assets/edu_bg.jpg")
	_build_ui()
	_refresh_choices()


func _build_ui() -> void:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var card := UiStyle.make_card_panel(Vector2(620, 0))
	center.add_child(card)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 16)
	card.add_child(v)

	v.add_child(UiStyle.make_step_tag("①／③　學歷"))

	var h := Label.new()
	h.text = "你點樣畢業？"
	UiStyle.apply_label(h, 30)
	v.add_child(h)

	var lead := Label.new()
	lead.text = "學歷唔決定成敗，但會決定第一份工嘅門檻同起薪帶。揀一條貼近自己嘅路。"
	lead.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lead.custom_minimum_size = Vector2(560, 0)
	UiStyle.apply_label(lead, 15, true)
	v.add_child(lead)

	_choices = VBoxContainer.new()
	_choices.add_theme_constant_override("separation", 14)
	v.add_child(_choices)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	v.add_child(row)

	var back := Button.new()
	back.text = "返回標題"
	UiStyle.apply_button(back, false)
	back.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/title.tscn")
	)
	row.add_child(back)

	_next_btn = Button.new()
	_next_btn.text = "繼續 · 揀職位"
	_next_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.apply_button(_next_btn, true)
	_next_btn.disabled = _selected == ""
	_next_btn.pressed.connect(_on_next)
	row.add_child(_next_btn)


func _refresh_choices() -> void:
	for c in _choices.get_children():
		c.queue_free()
	for edu_id in JobsData.education_ids():
		var edu: Dictionary = JobsData.get_education(edu_id)
		var btn := Button.new()
		btn.text = "%s\n%s" % [edu.get("title", ""), edu.get("desc", "")]
		UiStyle.apply_choice_button(btn, edu_id == _selected)
		var id_capture := str(edu_id)
		btn.pressed.connect(func() -> void:
			_selected = id_capture
			GameState.select_education(id_capture)
			_next_btn.disabled = false
			_refresh_choices()
		)
		_choices.add_child(btn)


func _on_next() -> void:
	if _selected == "":
		return
	GameState.select_education(_selected)
	get_tree().change_scene_to_file("res://scenes/job.tscn")
