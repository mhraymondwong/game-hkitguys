extends Control
## 開局②：入職職位 — E glass


var _choices: VBoxContainer
var _next_btn: Button
var _lead: Label
var _selected: String = ""


func _ready() -> void:
	if GameState.education_id == "":
		get_tree().change_scene_to_file("res://scenes/education.tscn")
		return
	_selected = GameState.job_id
	UiStyle.add_texture_background(self, "res://assets/job_bg.jpg")
	_build_ui()
	_refresh_choices()


func _build_ui() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 72)
	margin.add_theme_constant_override("margin_right", 72)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	add_child(margin)

	var card := UiStyle.make_card_panel(Vector2(0, 0))
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(card)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	card.add_child(v)

	v.add_child(UiStyle.make_step_tag("②／③　入職"))

	var h := Label.new()
	h.text = "第一份工，揀邊個？"
	UiStyle.apply_label(h, 30)
	v.add_child(h)

	_lead = Label.new()
	_lead.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(_lead, 15, true)
	v.add_child(_lead)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 340)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(scroll)

	_choices = VBoxContainer.new()
	_choices.add_theme_constant_override("separation", 12)
	_choices.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_choices)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	v.add_child(row)

	var back := Button.new()
	back.text = "返回學歷"
	UiStyle.apply_button(back, false)
	back.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/education.tscn")
	)
	row.add_child(back)

	_next_btn = Button.new()
	_next_btn.text = "繼續 · 睇 Offer"
	_next_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.apply_button(_next_btn, true)
	_next_btn.disabled = _selected == ""
	_next_btn.pressed.connect(_on_next)
	row.add_child(_next_btn)


func _refresh_choices() -> void:
	var edu := GameState.education_id
	var edu_title := GameConfig.education_title(edu)
	_lead.text = (
		"%s：開發／雲／BA 選擇較闊，起薪帶通常略高。Infra 同 App 都有得入。"
		% edu_title
		if edu == "uni"
		else "%s：支援／運維入門穩陣，Junior Dev 亦有得試。Infra 同 App 都有得入。"
		% edu_title
	)
	for c in _choices.get_children():
		c.queue_free()
	for job in JobsData.jobs_for_education(edu):
		if not (job is Dictionary):
			continue
		var jid := str(job.get("id", ""))
		var track := str(job.get("track", ""))
		var badge := GameConfig.track_label(track)
		var btn := Button.new()
		btn.text = "%s　·　%s\n月薪約 HK$%s　｜　%s" % [
			job.get("title", ""),
			badge,
			job.get("salary", ""),
			job.get("company", "")
		]
		UiStyle.apply_choice_button(btn, jid == _selected)
		if jid == _selected:
			var border := GameConfig.COL_INFRA if track == "infra" else GameConfig.COL_APP
			var sel := UiStyle.button_style(GameConfig.COL_TILE_SELECTED, border, 16)
			sel.content_margin_left = 18
			sel.content_margin_right = 18
			sel.content_margin_top = 14
			sel.content_margin_bottom = 14
			sel.shadow_color = Color(border.r, border.g, border.b, 0.55)
			sel.shadow_size = 14
			btn.add_theme_stylebox_override("normal", sel)
		var id_capture := jid
		btn.pressed.connect(func() -> void:
			_selected = id_capture
			GameState.select_job(id_capture)
			_next_btn.disabled = false
			_refresh_choices()
		)
		_choices.add_child(btn)


func _on_next() -> void:
	if _selected == "":
		return
	if not GameState.select_job(_selected):
		return
	get_tree().change_scene_to_file("res://scenes/offer.tscn")
