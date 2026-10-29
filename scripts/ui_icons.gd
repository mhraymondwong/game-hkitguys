class_name UiIcons
extends RefCounted
## Grok Imagine bias icons for hub activity rows (E glass RPG).


const ICON_DIR := "res://assets/ui/icons/"


static func bias_icon_path(bias: String, crisis: bool = false) -> String:
	if crisis:
		return ICON_DIR + "icon_bias_crisis.png"
	match bias:
		"infra":
			return ICON_DIR + "icon_bias_infra.png"
		"app":
			return ICON_DIR + "icon_bias_app.png"
		"manage":
			return ICON_DIR + "icon_bias_manage.png"
		"social":
			return ICON_DIR + "icon_bias_social.png"
		"study":
			return ICON_DIR + "icon_bias_study.png"
		"rest":
			return ICON_DIR + "icon_bias_rest.png"
		"career":
			return ICON_DIR + "icon_bias_career.png"
		"crisis":
			return ICON_DIR + "icon_bias_crisis.png"
		_:
			return ICON_DIR + "icon_bias_career.png"


static func load_bias_icon(bias: String, crisis: bool = false) -> Texture2D:
	var path := bias_icon_path(bias, crisis)
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D


## Map locations reuse hub bias art (no emoji — tofu-safe on web).
static func location_bias(location_id: String) -> String:
	match location_id:
		"company":
			return "infra"
		"cha-chaan-teng":
			return "social"
		"home":
			return "rest"
		"job-board":
			return "career"
		_:
			return "career"


static func load_location_icon(location_id: String) -> Texture2D:
	return load_bias_icon(location_bias(location_id), false)

