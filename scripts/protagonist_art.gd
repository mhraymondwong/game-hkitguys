class_name ProtagonistArt
extends RefCounted
## Phase D — pick portrait / fullbody by GameState health + last activity.
##
## Portrait (hub HUD / badge slots):
##   1. tired     — health ≤ 35
##                OR last id in grind set AND health ≤ 50
##                  (oncall-night, war-room, ticket-grind, patch-window)
##   2. confident — health ≥ 70
##                OR last id in {upward-chat, team-lunch, feature-sprint}
##   3. else portrait_badge.jpg
## Fullbody (all cutout PNG — 先退底，再叠在背景／其他圖上；禁止 JPG 棚底):
##   1. hoodie — last id deep-rest OR bias rest OR id team-lunch
##   2. formal — last id upward-chat OR title/context hints interview/boss
##   3. else fullbody.png
## Cinematic hub/month stage: cinematic_stage_path → stand_suit PNG only.
## Priority: check tired before confident; hoodie before formal.


const DIR := "res://assets/protagonist/"
const PORTRAIT_DEFAULT := DIR + "portrait_badge.jpg"
const PORTRAIT_TIRED := DIR + "portrait_tired.jpg"
const PORTRAIT_CONFIDENT := DIR + "portrait_confident.jpg"
const FULLBODY_DEFAULT := DIR + "fullbody.png"
const FULLBODY_HOODIE := DIR + "fullbody_hoodie.png"
const FULLBODY_FORMAL := DIR + "fullbody_formal.png"
const FULLBODY_STAND_SUIT := DIR + "fullbody_stand_suit.png"

const ALL_FILES := [
	PORTRAIT_DEFAULT,
	PORTRAIT_TIRED,
	PORTRAIT_CONFIDENT,
	FULLBODY_DEFAULT,
	FULLBODY_HOODIE,
	FULLBODY_FORMAL,
	FULLBODY_STAND_SUIT,
]

const GRIND_IDS := ["oncall-night", "war-room", "ticket-grind", "patch-window", "typhoon-wfh", "ransomware-drill", "mtr-overtime", "vpn-firefight", "cloud-migration"]
const CONFIDENT_IDS := ["upward-chat", "team-lunch", "feature-sprint", "bonus-talk", "mentor-junior", "meetup-night", "hackathon-blitz", "morning-daily", "cha-chaan-teng-round", "push-promo", "accept-hop"]
const FORMAL_HINTS := ["面試", "老闆", "boss", "interview", "skip-level", "向上"]


static func portrait_path(gs: Node = null) -> String:
	var health := _health(gs)
	var act_id := _act_id(gs)
	if health <= 35:
		return PORTRAIT_TIRED
	if act_id in GRIND_IDS and health <= 50:
		return PORTRAIT_TIRED
	if health >= 70:
		return PORTRAIT_CONFIDENT
	if act_id in CONFIDENT_IDS:
		return PORTRAIT_CONFIDENT
	return PORTRAIT_DEFAULT


static func fullbody_path(gs: Node = null) -> String:
	var act_id := _act_id(gs)
	var bias := _act_bias(gs)
	var title := _act_title(gs)
	if act_id == "deep-rest" or bias == "rest" or act_id in ["team-lunch", "side-project", "cha-chaan-teng-round", "hackathon-blitz"]:
		return FULLBODY_HOODIE
	if act_id in ["upward-chat", "bonus-talk", "mentor-junior", "perf-review-week", "push-promo", "interview-round", "accept-hop", "decline-hop"] or _title_hints_formal(title):
		return FULLBODY_FORMAL
	return FULLBODY_DEFAULT


## month_result first month: default fullbody; light confident portrait if health high.
static func month_result_fullbody_path(gs: Node = null) -> String:
	return fullbody_path(gs)


## Hub / month cinematic shell: always cutout stand_suit PNG (退底後叠 SceneBg／stage).
static func cinematic_stage_path(_gs: Node = null) -> String:
	return FULLBODY_STAND_SUIT


static func month_result_portrait_path(gs: Node = null) -> String:
	var health := _health(gs)
	if health >= 70:
		return PORTRAIT_CONFIDENT
	return PORTRAIT_DEFAULT


static func _health(gs: Node) -> int:
	if gs == null:
		gs = _autoload()
	if gs == null:
		return 100
	return int(gs.get("health"))


static func _act_id(gs: Node) -> String:
	if gs == null:
		gs = _autoload()
	if gs == null:
		return ""
	return str(gs.get("last_activity_id"))


static func _act_title(gs: Node) -> String:
	if gs == null:
		gs = _autoload()
	if gs == null:
		return ""
	return str(gs.get("last_activity_title"))


static func _act_bias(gs: Node) -> String:
	var id := _act_id(gs)
	if id == "":
		return ""
	var act: Dictionary = ActivitiesData.get_activity(id)
	return str(act.get("bias", ""))


static func _title_hints_formal(title: String) -> bool:
	var t := title.to_lower()
	for h in FORMAL_HINTS:
		if h.to_lower() in t:
			return true
	return false


static func _autoload() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("GameState")
