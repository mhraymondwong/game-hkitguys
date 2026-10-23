extends Control
## 城市／公司地圖殼 — 每計劃月可走一處；玻璃地點格


var _body: VBoxContainer
var _hint: Label
var _locs_wrap: GridContainer
var _result_panel: PanelContainer


func _ready() -> void:
	if GameState.job_id == "" or GameState.months_played < 1:
		get_tree().change_scene_to_file("res://scenes/title.tscn")
		return
	UiStyle.add_texture_background(self, "res://assets/month_bg.jpg")
	_build_ui()
	_refresh()


func _build_ui() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 22)
	add_child(margin)

	var root_v := VBoxContainer.new()
	root_v.add_theme_constant_override("separation", 12)
	root_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_v.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(root_v)

	var line1 := "%s　｜　城市／公司地圖" % GameState.calendar_label()
	var line2 := "%s　｜　%s　｜　%s　｜　本月地圖行動：%s" % [
		GameState.company_name,
		GameState.company_state_label(),
		GameState.job_title,
		"已用" if GameState.map_used_this_month else "尚可 1 次"
	]
	root_v.add_child(UiStyle.make_chrome_header(line1, line2))

	var card := UiStyle.make_card_panel()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_v.add_child(card)

	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 12)
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.add_child(_body)

	_body.add_child(UiStyle.make_step_tag("城市／公司"))

	var h := Label.new()
	h.text = "去邊度兜一轉？"
	UiStyle.apply_label(h, 24)
	_body.add_child(h)

	var lead := Label.new()
	lead.text = "唔取代本月活動——每月可額外走一處，觸發一段短事件再返計劃。"
	lead.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(lead, 14, true)
	_body.add_child(lead)

	_hint = Label.new()
	UiStyle.apply_label(_hint, 13, true)
	_body.add_child(_hint)

	_locs_wrap = GridContainer.new()
	_locs_wrap.columns = 2
	_locs_wrap.add_theme_constant_override("h_separation", 12)
	_locs_wrap.add_theme_constant_override("v_separation", 12)
	_locs_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_child(_locs_wrap)

	_result_panel = UiStyle.make_flavour_panel()
	_result_panel.visible = false
	_result_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_child(_result_panel)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	root_v.add_child(row)

	var back := Button.new()
	back.text = "返回本月計劃"
	back.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.apply_button(back, true)
	back.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/hub.tscn")
	)
	row.add_child(back)


func _refresh() -> void:
	for c in _locs_wrap.get_children():
		c.queue_free()
	for c in _result_panel.get_children():
		c.queue_free()

	var used := GameState.map_used_this_month
	if used and GameState.last_map_event_id != "":
		_hint.text = "本月已走完一處。下個月先再出街。"
		_show_result()
	elif used:
		_hint.text = "本月地圖行動已用完。"
		_result_panel.visible = false
	else:
		_hint.text = "揀一個地點。"
		_result_panel.visible = false

	for loc in MapData.all_locations():
		var id := str(loc.get("id", ""))
		var btn := Button.new()
		btn.text = "%s　%s\n%s" % [str(loc.get("icon", "")), str(loc.get("title", "")), str(loc.get("desc", ""))]
		btn.custom_minimum_size = Vector2(0, 96)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		UiStyle.apply_choice_button(btn, false)
		btn.disabled = used
		var id_cap := id
		btn.pressed.connect(func() -> void:
			_on_pick(id_cap)
		)
		_locs_wrap.add_child(btn)


func _on_pick(location_id: String) -> void:
	if not GameState.apply_map_visit(location_id):
		_hint.text = "而家去唔到呢度，返計劃再試。"
		return
	_refresh()


func _show_result() -> void:
	_result_panel.visible = true
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	_result_panel.add_child(v)

	var tag := Label.new()
	tag.text = "%s　·　%s" % [GameState.last_map_location_title, GameState.last_map_event_title]
	UiStyle.apply_label(tag, 16)
	tag.add_theme_color_override("font_color", GameConfig.COL_RIM_CYAN)
	v.add_child(tag)

	var delta := Label.new()
	delta.text = "變化：%s" % MapData.format_deltas(GameState.last_map_deltas)
	UiStyle.apply_label(delta, 14)
	delta.add_theme_color_override("font_color", GameConfig.COL_RIM_GOLD)
	v.add_child(delta)

	var fl := Label.new()
	fl.text = GameState.last_map_event_flavour
	fl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(fl, 14)
	v.add_child(fl)
