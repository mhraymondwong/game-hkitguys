extends Control
## 標題：《香港IT人》→ 開始入行／讀檔（遊戲名僅此畫面主標題）


const TITLE_BG := "res://assets/title_bg.jpg"
const PORTRAIT := "res://assets/protagonist/portrait_badge.jpg"
const FULLBODY := "res://assets/protagonist/fullbody.jpg"

var _slot_box: VBoxContainer
var _status: Label


func _ready() -> void:
	UiStyle.add_texture_background(self, TITLE_BG)
	_build_ui()
	_refresh_slots()


func _build_ui() -> void:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 36)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(row)

	var art_path := PORTRAIT if ResourceLoader.exists(PORTRAIT) or FileAccess.file_exists(ProjectSettings.globalize_path(PORTRAIT)) else FULLBODY
	var art := UiStyle.make_art_frame(art_path, Vector2(190, 262), true)
	row.add_child(art)

	var card := UiStyle.make_card_panel(Vector2(540, 0), true)
	row.add_child(card)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(v)

	v.add_child(UiStyle.make_step_tag("港式職場模擬"))

	var title := Label.new()
	title.text = "《香港IT人》"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiStyle.apply_label(title, 40)
	title.add_theme_color_override("font_color", GameConfig.COL_WHITE)
	v.add_child(title)

	var lead := Label.new()
	lead.text = "由畢業證到員工證——揀學歷、接第一份 offer，一步步寫你嘅 IT 人生。"
	lead.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lead.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lead.custom_minimum_size = Vector2(480, 0)
	UiStyle.apply_label(lead, 15, true)
	v.add_child(lead)

	var start_btn := Button.new()
	start_btn.text = "開始入行"
	UiStyle.apply_button(start_btn, true)
	start_btn.custom_minimum_size = Vector2(0, 56)
	start_btn.pressed.connect(_on_start)
	v.add_child(start_btn)

	var cont := Button.new()
	cont.text = "繼續最近進度"
	UiStyle.apply_button(cont, false)
	cont.pressed.connect(_on_continue)
	v.add_child(cont)

	var load_tag := Label.new()
	load_tag.text = "讀取存檔槽"
	load_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiStyle.apply_label(load_tag, 13, true)
	v.add_child(load_tag)

	_slot_box = VBoxContainer.new()
	_slot_box.add_theme_constant_override("separation", 8)
	v.add_child(_slot_box)

	_status = Label.new()
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.apply_label(_status, 12, true)
	v.add_child(_status)

	var tip := Label.new()
	tip.text = "三分鐘左右入到第一份工。慢慢揀就得。"
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiStyle.apply_label(tip, 12, true)
	v.add_child(tip)


func _refresh_slots() -> void:
	for c in _slot_box.get_children():
		c.queue_free()
	for i in range(1, SaveSystem.SLOT_COUNT + 1):
		var btn := Button.new()
		btn.text = "讀取　" + SaveSystem.slot_button_label(i)
		UiStyle.apply_button(btn, false)
		btn.disabled = not SaveSystem.slot_exists(i)
		var slot_i := i
		btn.pressed.connect(func() -> void:
			_load_slot(slot_i)
		)
		_slot_box.add_child(btn)
	if not SaveSystem.has_any_save():
		_status.text = "未有存檔。入職後可喺本月計劃存檔。"
	else:
		_status.text = "揀槽讀取，或按「繼續最近進度」。"


func _on_start() -> void:
	GameState.begin_new_game()
	get_tree().change_scene_to_file("res://scenes/education.tscn")


func _on_continue() -> void:
	var slot := SaveSystem.newest_slot()
	if slot < 1:
		_status.text = "未有可繼續嘅存檔。"
		return
	_load_slot(slot)


func _load_slot(slot: int) -> void:
	if not SaveSystem.load_slot(slot, GameState):
		_status.text = "讀取槽 %d 失敗。" % slot
		_refresh_slots()
		return
	var path := SaveSystem.scene_after_load(GameState)
	get_tree().change_scene_to_file(path)
