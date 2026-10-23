class_name SceneBg
extends RefCounted
## Phase 3b — atmosphere background by mood / job_level / grind activity.
## mid: no stage_* from level (falls through → overtime → per-scene fallback).


const DIR := "res://assets/bg/"
const BG_JUNIOR := DIR + "stage_junior_morning.jpg"
const BG_OVERTIME := DIR + "stage_overtime_night.jpg"
const BG_LEAD := DIR + "stage_lead_meeting.jpg"
const BG_MGMT := DIR + "stage_mgmt_harbour.jpg"
const BG_TYPHOON := DIR + "mood_typhoon_wfh.jpg"

const FALLBACK_HUB := "res://assets/job_bg.jpg"
const FALLBACK_MONTH := "res://assets/month_bg.jpg"
const FALLBACK_TITLE := "res://assets/title_bg.jpg"
const FALLBACK_EDU := "res://assets/edu_bg.jpg"

const ALL_FILES := [
	BG_JUNIOR,
	BG_OVERTIME,
	BG_LEAD,
	BG_MGMT,
	BG_TYPHOON,
]

const TYPHOON_EVENT_IDS := ["typhoon-signal"]
const TYPHOON_HINTS := ["typhoon", "颱風", "黑雨", "八號", "八号", "black-rain", "black_rain", "black rain"]
const OVERTIME_IDS := ["oncall-night", "war-room", "mtr-overtime", "vpn-firefight", "patch-window"]
const TYPHOON_SEASON_GRIND := ["oncall-night", "war-room", "vpn-firefight"]


static func path_for(gs: Node = null, fallback: String = FALLBACK_MONTH) -> String:
	if gs == null:
		gs = _autoload()
	var act := _str(gs, "last_activity_id")
	var ev := _str(gs, "last_event_id")
	var ev_title := _str(gs, "last_event_title")
	var season := _season(gs)
	var level := _str(gs, "job_level").strip_edges().to_lower()

	# 1. Mood: typhoon / black rain
	if act == "typhoon-wfh":
		return BG_TYPHOON
	if ev in TYPHOON_EVENT_IDS or _text_hints_typhoon(ev) or _text_hints_typhoon(ev_title):
		return BG_TYPHOON
	if season in ["summer", "autumn"] and act in TYPHOON_SEASON_GRIND:
		return BG_TYPHOON

	# 2. Career stage by job_level
	match level:
		"junior", "":
			return BG_JUNIOR
		"mid":
			pass  # mid → overtime check, else scene fallback (documented)
		"senior", "lead":
			return BG_LEAD
		"manager":
			return BG_MGMT
		_:
			if "manager" in level or "director" in level or "head" in level:
				return BG_MGMT
			# missing / unknown → junior morning
			return BG_JUNIOR

	# 3. Overtime grind (mid fallthrough)
	if act in OVERTIME_IDS:
		return BG_OVERTIME

	# 4. Per-scene fallback
	if fallback != "":
		return fallback
	return FALLBACK_MONTH


static func apply_to(parent: Control, gs: Node = null, fallback: String = FALLBACK_MONTH) -> void:
	UiStyle.add_texture_background(parent, path_for(gs, fallback))


static func _text_hints_typhoon(text: String) -> bool:
	var t := text.to_lower()
	for h in TYPHOON_HINTS:
		if str(h).to_lower() in t:
			return true
	return false


static func _season(gs: Node) -> String:
	if gs == null:
		return ""
	if gs.has_method("season_id"):
		return str(gs.call("season_id"))
	var m := 1
	if gs.get("month") != null:
		m = int(gs.get("month"))
	return ActivitiesData.season_of_month(m)


static func _str(gs: Node, key: String) -> String:
	if gs == null:
		return ""
	var v = gs.get(key)
	if v == null:
		return ""
	return str(v)


static func _autoload() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return null
	return tree.root.get_node_or_null("GameState")
