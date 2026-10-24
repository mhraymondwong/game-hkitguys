class_name UiStyle
extends RefCounted
## E glass RPG UI — frosted panels, cyan/gold rims, attribute rings, orange CTA


static var _ui_font: Font


static func ui_font() -> Font:
	if _ui_font == null:
		_ui_font = load(GameConfig.FONT_PATH) as Font
	return _ui_font


static func _apply_font(ctrl: Control) -> void:
	var f := ui_font()
	if f:
		ctrl.add_theme_font_override("font", f)


static func glass_style(
	bg: Color = GameConfig.COL_GLASS_STRONG,
	border: Color = GameConfig.COL_RIM_CYAN,
	radius: int = 20,
	glow: bool = true
) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(2)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 20
	s.content_margin_right = 20
	s.content_margin_top = 16
	s.content_margin_bottom = 16
	if glow:
		s.shadow_color = Color(border.r, border.g, border.b, 0.45)
		s.shadow_size = 16
		s.shadow_offset = Vector2(0, 0)
	else:
		s.shadow_color = Color(0.05, 0.1, 0.2, 0.35)
		s.shadow_size = 10
		s.shadow_offset = Vector2(0, 6)
	return s


static func panel_style(
	bg: Color = GameConfig.COL_CARD,
	border: Color = GameConfig.COL_CARD_BORDER,
	radius: int = 20
) -> StyleBoxFlat:
	return glass_style(bg, border, radius, true)


static func button_style(bg: Color, border: Color, radius: int = 14) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(2)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 13
	s.content_margin_bottom = 13
	s.shadow_color = Color(border.r, border.g, border.b, 0.35)
	s.shadow_size = 8
	s.shadow_offset = Vector2(0, 0)
	return s


static func apply_button(btn: Button, primary: bool = false) -> void:
	if primary:
		# Soft orange CTA with glow (solid fill so it reads on glass)
		var n := button_style(Color(0.91, 0.47, 0.25, 0.96), GameConfig.COL_ACCENT_SOFT, 28)
		n.shadow_color = GameConfig.COL_CTA_GLOW
		n.shadow_size = 22
		n.content_margin_top = 14
		n.content_margin_bottom = 14
		btn.add_theme_stylebox_override("normal", n)
		var h := button_style(Color(1.0, 0.62, 0.38, 0.98), GameConfig.COL_ACCENT, 28)
		h.shadow_color = GameConfig.COL_CTA_GLOW
		h.shadow_size = 26
		btn.add_theme_stylebox_override("hover", h)
		btn.add_theme_stylebox_override("pressed", button_style(Color("A84828"), Color("C45C3A"), 28))
		btn.add_theme_stylebox_override("disabled", button_style(Color(0.40, 0.34, 0.30, 0.70), Color(0.55, 0.48, 0.40, 0.45), 28))
		btn.add_theme_color_override("font_color", GameConfig.COL_WHITE)
		btn.add_theme_color_override("font_hover_color", GameConfig.COL_WHITE)
		btn.add_theme_color_override("font_pressed_color", GameConfig.COL_WHITE)
		btn.add_theme_color_override("font_disabled_color", Color(0.75, 0.7, 0.65, 0.7))
		btn.add_theme_font_size_override("font_size", 19)
		btn.custom_minimum_size = Vector2(0, 54)
	else:
		btn.add_theme_stylebox_override("normal", button_style(GameConfig.COL_GLASS_SOFT, GameConfig.COL_TILE_BORDER, 16))
		btn.add_theme_stylebox_override("hover", button_style(GameConfig.COL_CHIP_HOVER, GameConfig.COL_RIM_CYAN, 16))
		btn.add_theme_stylebox_override("pressed", button_style(GameConfig.COL_TILE_SELECTED, GameConfig.COL_RIM_GOLD, 16))
		btn.add_theme_stylebox_override("disabled", button_style(Color(0.2, 0.25, 0.35, 0.35), Color(0.4, 0.45, 0.55, 0.3), 16))
		btn.add_theme_color_override("font_color", GameConfig.COL_TEXT)
		btn.add_theme_color_override("font_hover_color", GameConfig.COL_TEXT)
		btn.add_theme_color_override("font_pressed_color", GameConfig.COL_TEXT)
		btn.add_theme_color_override("font_disabled_color", GameConfig.COL_TEXT_MUTED)
		btn.add_theme_font_size_override("font_size", 17)
		btn.custom_minimum_size = Vector2(120, 48)
	_apply_font(btn)


static func apply_choice_button(btn: Button, selected: bool = false) -> void:
	var fill := GameConfig.COL_TILE_SELECTED if selected else GameConfig.COL_TILE
	var border := GameConfig.COL_RIM_CYAN if selected else GameConfig.COL_TILE_BORDER
	var normal := button_style(fill, border, 16)
	normal.content_margin_left = 18
	normal.content_margin_right = 18
	normal.content_margin_top = 14
	normal.content_margin_bottom = 14
	if selected:
		normal.shadow_color = Color(GameConfig.COL_RIM_CYAN.r, GameConfig.COL_RIM_CYAN.g, GameConfig.COL_RIM_CYAN.b, 0.65)
		normal.shadow_size = 16
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", button_style(GameConfig.COL_TILE_SELECTED, GameConfig.COL_RIM_CYAN, 16))
	btn.add_theme_stylebox_override("pressed", button_style(GameConfig.COL_TILE_SELECTED, GameConfig.COL_RIM_GOLD, 16))
	btn.add_theme_color_override("font_color", GameConfig.COL_TEXT)
	btn.add_theme_color_override("font_hover_color", GameConfig.COL_TEXT)
	btn.add_theme_color_override("font_pressed_color", GameConfig.COL_TEXT)
	btn.add_theme_font_size_override("font_size", 16)
	_apply_font(btn)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.custom_minimum_size = Vector2(0, 78)


static func apply_label(lbl: Label, size: int = 18, muted: bool = false) -> void:
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", GameConfig.COL_TEXT_MUTED if muted else GameConfig.COL_TEXT)
	_apply_font(lbl)


static func apply_rich_label(rtl: RichTextLabel, size: int = 16) -> void:
	rtl.add_theme_font_size_override("normal_font_size", size)
	rtl.add_theme_color_override("default_color", GameConfig.COL_TEXT)
	_apply_font(rtl)
	var f := ui_font()
	if f:
		rtl.add_theme_font_override("normal_font", f)


## High-contrast step/section tag: soft cyan-white on dark cyan pill (E glass RPG).
static func make_step_tag(text: String) -> PanelContainer:
	var wrap := PanelContainer.new()
	wrap.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var sb := glass_style(GameConfig.COL_TAG_BG, GameConfig.COL_RIM_CYAN, 20, true)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	sb.shadow_size = 8
	wrap.add_theme_stylebox_override("panel", sb)
	var tag := Label.new()
	tag.text = text
	apply_label(tag, 13, true)
	tag.add_theme_color_override("font_color", GameConfig.COL_TAG_FG)
	wrap.add_child(tag)
	return wrap


## Compact glass chip for month-result stats.
static func make_stat_chip(caption: String, value: String, accent: Color = GameConfig.COL_RIM_CYAN) -> PanelContainer:
	var box := PanelContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb := glass_style(GameConfig.COL_GLASS_LIGHT, accent, 14, true)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	sb.shadow_size = 8
	box.add_theme_stylebox_override("panel", sb)
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 4)
	box.add_child(sv)
	var sl := Label.new()
	sl.text = caption
	sl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	apply_label(sl, 12, true)
	sv.add_child(sl)
	var svl := Label.new()
	svl.text = value
	svl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	apply_label(svl, 22)
	svl.add_theme_color_override("font_color", accent)
	sv.add_child(svl)
	return box


## Build layered dusk sky background under a Control root.
static func add_sky_background(parent: Control) -> void:
	var sky := ColorRect.new()
	sky.name = "SkyBase"
	sky.color = GameConfig.COL_SKY_TOP
	sky.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(sky)
	parent.move_child(sky, 0)

	var mid := ColorRect.new()
	mid.color = Color(GameConfig.COL_SKY_MID.r, GameConfig.COL_SKY_MID.g, GameConfig.COL_SKY_MID.b, 0.55)
	mid.set_anchors_preset(Control.PRESET_FULL_RECT)
	mid.anchor_top = 0.28
	mid.anchor_bottom = 0.62
	mid.offset_top = 0
	mid.offset_bottom = 0
	mid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(mid)
	parent.move_child(mid, 1)

	var warm := ColorRect.new()
	warm.color = Color(GameConfig.COL_SKY_WARM.r, GameConfig.COL_SKY_WARM.g, GameConfig.COL_SKY_WARM.b, 0.75)
	warm.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	warm.anchor_top = 0.58
	warm.offset_top = 0
	warm.offset_bottom = 0
	warm.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(warm)

	var glow := ColorRect.new()
	glow.color = Color(1.0, 0.9, 0.7, 0.28)
	glow.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	glow.anchor_left = 0.72
	glow.anchor_top = 0.02
	glow.anchor_right = 0.98
	glow.anchor_bottom = 0.38
	glow.offset_left = 0
	glow.offset_top = 0
	glow.offset_right = 0
	glow.offset_bottom = 0
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(glow)

	var city := ColorRect.new()
	city.color = Color(0.08, 0.12, 0.2, 0.55)
	city.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	city.anchor_top = 0.82
	city.offset_top = 0
	city.offset_bottom = 0
	city.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(city)


## Full-bleed Grok Imagine background + light wash; fall back to procedural sky.
static func add_texture_background(parent: Control, path: String) -> void:
	var exists := ResourceLoader.exists(path) or FileAccess.file_exists(ProjectSettings.globalize_path(path))
	if not exists:
		add_sky_background(parent)
		return
	var bg := TextureRect.new()
	bg.name = "ImagineBg"
	bg.texture = load(path)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(bg)
	parent.move_child(bg, 0)
	var wash := ColorRect.new()
	wash.name = "ImagineWash"
	# Soft cool wash so glass panels float over office art
	wash.color = Color(0.08, 0.14, 0.28, 0.28)
	wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(wash)
	parent.move_child(wash, 1)


static func make_card_panel(min_size: Vector2 = Vector2(520, 0), gold_rim: bool = false) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = min_size
	var rim := GameConfig.COL_RIM_GOLD if gold_rim else GameConfig.COL_RIM_CYAN
	panel.add_theme_stylebox_override("panel", glass_style(GameConfig.COL_GLASS_STRONG, rim, 22, true))
	return panel


## Soft-framed TextureRect for Grok Imagine character art.
static func make_art_rect(path: String, min_size: Vector2, cover: bool = true) -> TextureRect:
	var tr := TextureRect.new()
	tr.name = "ImagineArt"
	tr.custom_minimum_size = min_size
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED if cover else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(path) or FileAccess.file_exists(ProjectSettings.globalize_path(path)):
		tr.texture = load(path)
	return tr


## Glass frame around character art.
static func make_art_frame(path: String, min_size: Vector2, cover: bool = true) -> PanelContainer:
	var frame := PanelContainer.new()
	var sb := glass_style(GameConfig.COL_GLASS_LIGHT, GameConfig.COL_RIM_GOLD, 16, true)
	sb.set_content_margin_all(6)
	sb.shadow_size = 14
	frame.add_theme_stylebox_override("panel", sb)
	frame.add_child(make_art_rect(path, min_size, cover))
	return frame


## Compact glass employee badge (no game-title chrome).
static func make_badge_panel(portrait_path: String, portrait_size: Vector2 = Vector2(140, 180), caption: String = "員工證") -> PanelContainer:
	var badge := PanelContainer.new()
	var sb := glass_style(GameConfig.COL_GLASS_STRONG, GameConfig.COL_RIM_GOLD, 16, true)
	sb.content_margin_left = 0
	sb.content_margin_right = 0
	sb.content_margin_top = 0
	sb.content_margin_bottom = 12
	badge.add_theme_stylebox_override("panel", sb)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	badge.add_child(v)

	var header := PanelContainer.new()
	var hsb := StyleBoxFlat.new()
	hsb.bg_color = Color(GameConfig.COL_ACCENT.r, GameConfig.COL_ACCENT.g, GameConfig.COL_ACCENT.b, 0.85)
	hsb.corner_radius_top_left = 14
	hsb.corner_radius_top_right = 14
	hsb.corner_radius_bottom_right = 0
	hsb.corner_radius_bottom_left = 0
	hsb.content_margin_left = 12
	hsb.content_margin_right = 12
	hsb.content_margin_top = 8
	hsb.content_margin_bottom = 8
	header.add_theme_stylebox_override("panel", hsb)
	var hl := Label.new()
	hl.text = "員工證"
	hl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	apply_label(hl, 12)
	hl.add_theme_color_override("font_color", GameConfig.COL_WHITE)
	header.add_child(hl)
	v.add_child(header)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 8)
	var bm := MarginContainer.new()
	bm.add_theme_constant_override("margin_left", 12)
	bm.add_theme_constant_override("margin_right", 12)
	bm.add_theme_constant_override("margin_top", 12)
	bm.add_theme_constant_override("margin_bottom", 0)
	bm.add_child(body)
	v.add_child(bm)

	body.add_child(make_art_rect(portrait_path, portrait_size, true))
	var cap := Label.new()
	cap.text = caption
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	apply_label(cap, 12, true)
	cap.add_theme_color_override("font_color", GameConfig.COL_TAG_FG)
	body.add_child(cap)
	return badge


## HUD / chrome header — year·month / job / salary. Never prints game title.
static func make_chrome_header(line1: String, line2: String = "") -> PanelContainer:
	var hud := PanelContainer.new()
	var sb := glass_style(GameConfig.COL_GLASS_STRONG, GameConfig.COL_RIM_GOLD, 18, true)
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	hud.add_theme_stylebox_override("panel", sb)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	hud.add_child(v)

	var t1 := Label.new()
	t1.text = line1
	t1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t1.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	apply_label(t1, 18)
	v.add_child(t1)

	if line2 != "":
		var t2 := Label.new()
		t2.text = line2
		t2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		t2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		apply_label(t2, 13, true)
		v.add_child(t2)
	return hud


## Coloured vertical / horizontal progress bar for a stat.
static func make_stat_bar(stat_key: String, value: int, wide: bool = true) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	box.add_child(row)
	var name_l := Label.new()
	name_l.text = GameConfig.stat_label(stat_key)
	name_l.custom_minimum_size = Vector2(48, 0)
	apply_label(name_l, 12, true)
	name_l.add_theme_color_override("font_color", GameConfig.bar_color(stat_key))
	row.add_child(name_l)
	var val_l := Label.new()
	val_l.text = str(value)
	val_l.custom_minimum_size = Vector2(28, 0)
	apply_label(val_l, 13)
	row.add_child(val_l)
	var track := ProgressBar.new()
	track.min_value = 0
	track.max_value = GameConfig.STAT_MAX
	track.value = value
	track.show_percentage = false
	track.custom_minimum_size = Vector2(120 if wide else 80, 10)
	track.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var fill := StyleBoxFlat.new()
	fill.bg_color = GameConfig.bar_color(stat_key)
	fill.set_corner_radius_all(6)
	var bg := StyleBoxFlat.new()
	bg.bg_color = GameConfig.COL_BAR_TRACK
	bg.set_corner_radius_all(6)
	track.add_theme_stylebox_override("fill", fill)
	track.add_theme_stylebox_override("background", bg)
	box.add_child(track)
	return box


## Portrait with five glowing attribute orbs arranged in a ring (E mock).
static func make_stat_ring_portrait(portrait_path: String, stats: Dictionary, size: Vector2 = Vector2(320, 360)) -> Control:
	var root := Control.new()
	root.custom_minimum_size = size
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var glass := PanelContainer.new()
	glass.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	glass.add_theme_stylebox_override("panel", glass_style(GameConfig.COL_GLASS, GameConfig.COL_RIM_GOLD, 22, true))
	root.add_child(glass)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	glass.add_child(center)

	var art_wrap := PanelContainer.new()
	var asb := glass_style(GameConfig.COL_GLASS_LIGHT, Color(1, 1, 1, 0.55), 14, false)
	asb.set_content_margin_all(4)
	art_wrap.add_theme_stylebox_override("panel", asb)
	art_wrap.add_child(make_art_rect(portrait_path, Vector2(148, 190), true))
	center.add_child(art_wrap)

	# Orbs as absolute children of root (after glass so they sit on top)
	var keys := ["app", "manage", "influence", "health", "infra"]
	# Angles: top, top-right, bottom-right, bottom, top-left (degrees from +X, CCW from east → use from -90)
	var angles := [-90.0, -18.0, 54.0, 126.0, -162.0]
	var cx := size.x * 0.5
	var cy := size.y * 0.5
	var radius := minf(size.x, size.y) * 0.42

	for i in keys.size():
		var key: String = keys[i]
		var ang_rad := deg_to_rad(angles[i])
		var ox := cx + cos(ang_rad) * radius - 34
		var oy := cy + sin(ang_rad) * radius - 34
		var val := int(stats.get(key, 0))
		var orb := _make_stat_orb(key, val)
		orb.position = Vector2(ox, oy)
		root.add_child(orb)

	return root


static func _make_stat_orb(stat_key: String, value: int) -> PanelContainer:
	var col := GameConfig.bar_color(stat_key)
	var orb := PanelContainer.new()
	orb.custom_minimum_size = Vector2(68, 68)
	var sb := StyleBoxFlat.new()
	# Fill intensity scales with value
	var t := clampf(float(value) / float(GameConfig.STAT_MAX), 0.15, 1.0)
	sb.bg_color = Color(col.r, col.g, col.b, 0.25 + 0.45 * t)
	sb.border_color = Color(col.r, col.g, col.b, 0.55 + 0.4 * t)
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(34)
	sb.content_margin_left = 4
	sb.content_margin_right = 4
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	sb.shadow_color = Color(col.r, col.g, col.b, 0.55)
	sb.shadow_size = 12
	sb.shadow_offset = Vector2(0, 0)
	orb.add_theme_stylebox_override("panel", sb)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	orb.add_child(v)

	var name_l := Label.new()
	name_l.text = GameConfig.stat_label(stat_key)
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	apply_label(name_l, 11)
	name_l.add_theme_color_override("font_color", GameConfig.COL_WHITE)
	v.add_child(name_l)

	var val_l := Label.new()
	val_l.text = str(value)
	val_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	apply_label(val_l, 16)
	val_l.add_theme_color_override("font_color", GameConfig.COL_WHITE)
	v.add_child(val_l)
	return orb


## Inner flavour / quote glass box.
static func make_flavour_panel() -> PanelContainer:
	var p := PanelContainer.new()
	var sb := glass_style(GameConfig.COL_GLASS_SOFT, GameConfig.COL_TILE_BORDER, 14, false)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	p.add_theme_stylebox_override("panel", sb)
	return p
