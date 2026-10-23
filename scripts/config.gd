class_name GameConfig
extends RefCounted
## 《香港IT人》顏色／常數 — E glass RPG（2026-10-22 LOCKED）

const VIEW_W := 1280
const VIEW_H := 720

# Soft dusk sky palette (fallback when Imagine BG missing)
const COL_SKY_TOP := Color("1A3A6E")
const COL_SKY_MID := Color("4A8FD4")
const COL_SKY_WARM := Color("F0A060")
const COL_SKY_GLOW := Color("FFE8C8")
const COL_INK := Color("1A2433")
const COL_INK_SOFT := Color("3D4F66")

# E glass RPG surfaces (frosted, translucent)
const COL_GLASS := Color(0.12, 0.22, 0.38, 0.42)
const COL_GLASS_STRONG := Color(0.10, 0.18, 0.32, 0.55)
const COL_GLASS_SOFT := Color(0.18, 0.30, 0.48, 0.36)
const COL_GLASS_LIGHT := Color(0.95, 0.97, 1.0, 0.22)
const COL_GLASS_BORDER := Color(0.55, 0.85, 1.0, 0.55)
const COL_RIM_CYAN := Color(0.35, 0.85, 1.0, 0.85)
const COL_RIM_GOLD := Color(1.0, 0.82, 0.40, 0.78)
const COL_TILE := Color(0.14, 0.24, 0.40, 0.48)
const COL_TILE_SELECTED := Color(0.18, 0.38, 0.58, 0.62)
const COL_TILE_BORDER := Color(0.70, 0.88, 1.0, 0.40)

# Legacy aliases → glass
const COL_CARD := COL_GLASS_STRONG
const COL_CARD_BORDER := COL_GLASS_BORDER

# Accents / soft orange CTA
const COL_ACCENT := Color("E87840")
const COL_ACCENT_SOFT := Color("FFB080")
const COL_ACCENT_DARK := Color("C45C3A")
const COL_CTA_GLOW := Color(0.95, 0.55, 0.22, 0.55)

# Track chips
const COL_INFRA := Color("3DDB8A")
const COL_APP := Color("4AA8F0")
const COL_GOOD := Color("4ADE80")

# E mock ring colours: Infra green / App blue / 管理 cyan / 影響 gold / 健康 red
const COL_BAR_INFRA := Color("3DDB8A")
const COL_BAR_APP := Color("4AA8F0")
const COL_BAR_MANAGE := Color("3DE0E8")
const COL_BAR_INFLUENCE := Color("F0C040")
const COL_BAR_HEALTH := Color("F06070")
const COL_BAR_TRACK := Color(1.0, 1.0, 1.0, 0.18)

const COL_CHIP := Color(0.20, 0.32, 0.48, 0.55)
const COL_CHIP_HOVER := Color(0.28, 0.42, 0.60, 0.65)

# Light text on glass (E mock)
const COL_TEXT := Color(0.98, 0.99, 1.0, 0.96)
const COL_TEXT_MUTED := Color(0.78, 0.88, 0.96, 0.88)
const COL_TEXT_DARK := Color("1A2433")
const COL_WHITE := Color(1, 1, 1, 1)

const FONT_PATH := "res://assets/fonts/NotoSansCJKtc-Regular.otf"
const STAT_MAX := 100


static func track_label(track: String) -> String:
	return "Infra" if track == "infra" else "App"


static func education_title(edu_id: String) -> String:
	match edu_id:
		"diploma":
			return "綜合畢業"
		"uni":
			return "大學畢業"
		_:
			return edu_id


static func bar_color(stat_key: String) -> Color:
	match stat_key:
		"infra":
			return COL_BAR_INFRA
		"app":
			return COL_BAR_APP
		"manage":
			return COL_BAR_MANAGE
		"influence":
			return COL_BAR_INFLUENCE
		"health":
			return COL_BAR_HEALTH
		_:
			return COL_ACCENT


static func stat_label(stat_key: String) -> String:
	match stat_key:
		"infra":
			return "Infra"
		"app":
			return "App"
		"manage":
			return "管理"
		"influence":
			return "影響"
		"health":
			return "健康"
		_:
			return stat_key
