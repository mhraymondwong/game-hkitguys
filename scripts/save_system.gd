class_name SaveSystem
extends RefCounted
## 多槽存檔（JSON → user://saves/）— 3 槽


const SLOT_COUNT := 3
const SAVE_DIR := "user://saves/"
const FORMAT_VERSION := 3


static func ensure_dir() -> void:
	var abs_dir := ProjectSettings.globalize_path(SAVE_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)


static func slot_path(slot: int) -> String:
	return "%sslot_%d.json" % [SAVE_DIR, clampi(slot, 1, SLOT_COUNT)]


static func slot_exists(slot: int) -> bool:
	if slot < 1 or slot > SLOT_COUNT:
		return false
	return FileAccess.file_exists(slot_path(slot))


static func read_meta(slot: int) -> Dictionary:
	var raw := _read_raw(slot)
	if raw.is_empty():
		return {}
	return {
		"slot": slot,
		"version": int(raw.get("version", 0)),
		"saved_at": str(raw.get("saved_at", "")),
		"summary": str(raw.get("summary", "")),
		"months_played": int(raw.get("state", {}).get("months_played", 0)),
		"job_title": str(raw.get("state", {}).get("job_title", "")),
		"year": int(raw.get("state", {}).get("year", 0)),
		"month": int(raw.get("state", {}).get("month", 0)),
	}


static func slot_button_label(slot: int) -> String:
	var meta := read_meta(slot)
	if meta.is_empty():
		return "槽 %d　·　空" % slot
	var summary := str(meta.get("summary", ""))
	if summary == "":
		summary = "有存檔"
	return "槽 %d　·　%s" % [slot, summary]


static func has_any_save() -> bool:
	for i in range(1, SLOT_COUNT + 1):
		if slot_exists(i):
			return true
	return false


static func newest_slot() -> int:
	var best := -1
	var best_ts := ""
	for i in range(1, SLOT_COUNT + 1):
		var meta := read_meta(i)
		if meta.is_empty():
			continue
		var ts := str(meta.get("saved_at", ""))
		if best < 0 or ts >= best_ts:
			best = i
			best_ts = ts
	return best


static func save_slot(slot: int, gs: Node) -> bool:
	if slot < 1 or slot > SLOT_COUNT:
		return false
	if gs == null or not gs.has_method("to_save_dict"):
		return false
	ensure_dir()
	var state: Dictionary = gs.call("to_save_dict")
	var summary := _make_summary(state)
	var payload := {
		"version": FORMAT_VERSION,
		"saved_at": Time.get_datetime_string_from_system(false, true),
		"summary": summary,
		"state": state,
	}
	var path := slot_path(slot)
	var fa := FileAccess.open(path, FileAccess.WRITE)
	if fa == null:
		return false
	fa.store_string(JSON.stringify(payload, "\t"))
	fa.close()
	return true


static func load_slot(slot: int, gs: Node) -> bool:
	if slot < 1 or slot > SLOT_COUNT:
		return false
	if gs == null or not gs.has_method("apply_save_dict"):
		return false
	var raw := _read_raw(slot)
	if raw.is_empty():
		return false
	var state: Dictionary = raw.get("state", {})
	if state.is_empty():
		return false
	gs.call("apply_save_dict", state)
	return true


static func clear_slot(slot: int) -> void:
	if not slot_exists(slot):
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(slot_path(slot)))


static func clear_all_for_tests() -> void:
	for i in range(1, SLOT_COUNT + 1):
		clear_slot(i)


static func scene_after_load(gs: Node) -> String:
	## Prefer hub if months_played>0; else resume opening flow.
	if gs == null:
		return "res://scenes/title.tscn"
	var played := int(gs.get("months_played"))
	var job_id := str(gs.get("job_id"))
	var edu := str(gs.get("education_id"))
	if played > 0 and job_id != "":
		return "res://scenes/hub.tscn"
	if job_id != "":
		return "res://scenes/offer.tscn"
	if edu != "":
		return "res://scenes/job.tscn"
	return "res://scenes/education.tscn"


static func _read_raw(slot: int) -> Dictionary:
	if not slot_exists(slot):
		return {}
	var fa := FileAccess.open(slot_path(slot), FileAccess.READ)
	if fa == null:
		return {}
	var text := fa.get_as_text()
	fa.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed as Dictionary


static func _make_summary(state: Dictionary) -> String:
	var y := int(state.get("year", 1))
	var m := int(state.get("month", 1))
	var title := str(state.get("job_title", ""))
	if title == "":
		title = "未入職"
	var played := int(state.get("months_played", 0))
	var co := str(state.get("company_state", ""))
	var co_bit := ""
	if co != "":
		co_bit = "　·　" + str(CompaniesData.state_label(co))
	var cl := str(state.get("market_climate", ""))
	var cl_bit := ""
	if cl != "":
		cl_bit = "　·　" + str(LaborMarketData.label(cl))
	return "第%d年·%d月　%s%s%s　·　已過%d月" % [y, m, title, co_bit, cl_bit, played]
