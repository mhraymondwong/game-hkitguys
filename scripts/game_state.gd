extends Node
## Autoload — 《香港IT人》開局＋月迴圈＋季節／事件＋存檔／地圖＋公司／職涯＋勞動市場／裁員（Phase 5.x）


var education_id: String = ""
var job_id: String = ""
var company_name: String = ""
var company_id: String = ""
var company_state: String = "stable"
var salary: String = ""
var salary_num: int = 0
var track: String = ""
var job_title: String = ""
var job_level: String = "junior"

var infra: int = 0
var app: int = 0
var manage: int = 0
var influence: int = 0
var health: int = 100

var year: int = 1
var month: int = 1
var months_played: int = 0

var tenure_months: int = 0
var performance: int = 50
var on_probation: bool = false
var probation_months_left: int = 0
## One-shot: true on the resolve after probation clears (celebrate once).
var last_probation_ended: bool = false
var hunt_progress: int = 0

var last_month_flavour: String = ""
var last_activity_id: String = ""
var last_activity_title: String = ""
var last_deltas: Dictionary = {}
## Month-resolve transparency: performance / salary change this resolve
var last_performance_delta: int = 0
var last_salary_delta: int = 0
var last_salary_before: int = 0
## Empty when salary moved; else player-facing why flat + next window.
var last_salary_hold_reason: String = ""
## Times each activity id was resolved (flavour rotation).
var activity_use_counts: Dictionary = {}

var last_event_id: String = ""
var last_event_title: String = ""
var last_event_flavour: String = ""
var last_event_deltas: Dictionary = {}

## Side map action: at most one visit per planning month.
var map_used_this_month: bool = false
var last_map_location_id: String = ""
var last_map_location_title: String = ""
var last_map_event_id: String = ""
var last_map_event_title: String = ""
var last_map_event_flavour: String = ""
var last_map_deltas: Dictionary = {}

## Company / career resolution flavour (shown on month_resolve / hub).
var last_company_state: String = ""
var last_company_changed: bool = false
var last_company_flavour: String = ""
var last_career_kind: String = ""  # "", promo, raise, pip, hop, offer, decline
var last_career_title: String = ""
var last_career_flavour: String = ""

## Pending external offer (Dictionary or empty).
var pending_offer: Dictionary = {}

## Phase 5.x — labor market climate + layoff / crisis month
var market_climate: String = "balanced"
var last_climate_changed: bool = false
var last_climate_flavour: String = ""
## When true, hub replaces normal picks with crisis-stay / severance / hunt-now
var crisis_active: bool = false
var crisis_kind: String = ""
var forced_job_hunt: bool = false
var last_crisis_kind: String = ""
var last_crisis_title: String = ""
var last_crisis_flavour: String = ""


func _ready() -> void:
	reset()


func begin_new_game() -> void:
	reset()


func reset() -> void:
	education_id = ""
	job_id = ""
	company_name = ""
	company_id = ""
	company_state = "stable"
	salary = ""
	salary_num = 0
	track = ""
	job_title = ""
	job_level = "junior"
	infra = 0
	app = 0
	manage = 0
	influence = 0
	health = 100
	year = 1
	month = 1
	months_played = 0
	tenure_months = 0
	performance = 50
	on_probation = false
	probation_months_left = 0
	last_probation_ended = false
	hunt_progress = 0
	last_month_flavour = ""
	last_activity_id = ""
	last_activity_title = ""
	last_deltas = {}
	last_performance_delta = 0
	last_salary_delta = 0
	last_salary_before = 0
	last_salary_hold_reason = ""
	activity_use_counts = {}
	_clear_event()
	_clear_map_result()
	map_used_this_month = false
	_clear_career_result()
	last_company_state = ""
	last_company_changed = false
	last_company_flavour = ""
	pending_offer = {}
	_clear_market_crisis()


func select_education(edu_id: String) -> bool:
	if JobsData.get_education(edu_id).is_empty():
		return false
	education_id = edu_id
	job_id = ""
	company_name = ""
	company_id = ""
	company_state = "stable"
	salary = ""
	salary_num = 0
	track = ""
	job_title = ""
	job_level = "junior"
	tenure_months = 0
	performance = 50
	on_probation = false
	probation_months_left = 0
	last_probation_ended = false
	hunt_progress = 0
	pending_offer = {}
	last_month_flavour = ""
	last_activity_id = ""
	last_activity_title = ""
	last_deltas = {}
	last_performance_delta = 0
	last_salary_delta = 0
	last_salary_before = 0
	last_salary_hold_reason = ""
	activity_use_counts = {}
	_clear_event()
	_clear_map_result()
	_clear_career_result()
	map_used_this_month = false
	_clear_market_crisis()
	return true


func select_job(jid: String) -> bool:
	var job: Dictionary = JobsData.get_job(education_id, jid)
	if job.is_empty():
		return false
	job_id = jid
	job_title = str(job.get("title", ""))
	company_name = str(job.get("company", ""))
	company_id = CompaniesData.resolve_company_id_from_job(job)
	var co: Dictionary = CompaniesData.get_company(company_id)
	if not co.is_empty():
		company_name = str(co.get("name", company_name))
		company_state = str(co.get("start_state", "stable"))
	else:
		company_state = "stable"
	salary = str(job.get("salary", ""))
	salary_num = CompaniesData.parse_salary_mid(salary)
	salary = CompaniesData.format_salary(salary_num)
	track = str(job.get("track", ""))
	job_level = "junior"
	return true


func current_job() -> Dictionary:
	return JobsData.get_job(education_id, job_id)


func accept_offer_and_run_first_month() -> bool:
	var job: Dictionary = current_job()
	if job.is_empty():
		return false
	var st: Dictionary = job.get("stats", {})
	infra = int(st.get("infra", 0))
	app = int(st.get("app", 0))
	manage = int(st.get("manage", 0))
	influence = int(st.get("influence", 0))
	health = int(st.get("health", 100))
	_clamp_stats()
	last_month_flavour = str(job.get("flavour", ""))
	last_activity_id = ""
	last_activity_title = "入職第一個月"
	last_deltas = {}
	last_performance_delta = 0
	last_salary_delta = 0
	last_salary_before = 0
	activity_use_counts = {}
	_clear_event()
	_clear_map_result()
	_clear_career_result()
	map_used_this_month = false
	year = 1
	month = 1
	months_played = 1
	tenure_months = 1
	performance = 55
	on_probation = true
	probation_months_left = 3
	last_probation_ended = false
	last_salary_hold_reason = "人工未變——入職首月／試用期內；正式調薪要轉正＋夠年資，再用「爭取升職／加薪」。"
	hunt_progress = 0
	pending_offer = {}
	last_company_state = company_state
	last_company_changed = false
	last_company_flavour = CompaniesData.state_flavour(company_state)
	market_climate = "balanced"
	last_climate_changed = false
	last_climate_flavour = LaborMarketData.resolve_flavour(market_climate)
	crisis_active = false
	crisis_kind = ""
	forced_job_hunt = false
	_clear_crisis_result()
	return true


## After a resolved month: move calendar to the next month to plan.
func prepare_next_month() -> void:
	month += 1
	if month > 12:
		month = 1
		year += 1
	map_used_this_month = false


func advance_month() -> void:
	prepare_next_month()


func season_id() -> String:
	return ActivitiesData.season_of_month(month)


func season_label() -> String:
	return ActivitiesData.season_label(season_id())


func season_label_full() -> String:
	return ActivitiesData.season_label_full(season_id())


func calendar_label() -> String:
	return "第 %d 年 · %d 月 · %s" % [year, month, season_label()]


func company_state_label() -> String:
	return CompaniesData.state_label(company_state)


func climate_label() -> String:
	return LaborMarketData.label(market_climate)


func climate_hub_line() -> String:
	## Unchanged climate → short chip; changed → full canonical flavour.
	if not last_climate_changed:
		return LaborMarketData.climate_chip(market_climate)
	return LaborMarketData.hub_flavour(market_climate)


func company_hub_line() -> String:
	## Unchanged company state → short chip; changed → canonical flavour.
	if not last_company_changed:
		return CompaniesData.state_chip(company_state)
	return CompaniesData.state_flavour(company_state)


func is_crisis_month() -> bool:
	return crisis_active


func job_level_label() -> String:
	return CompaniesData.level_label(job_level)


func apply_activity(id: String, roll_event: bool = true) -> bool:
	var act: Dictionary = ActivitiesData.get_activity(id)
	if act.is_empty():
		return false
	if job_id == "":
		return false
	var perf_before := performance
	var sal_before := salary_num
	_clear_career_result()
	last_company_changed = false

	# Career / crisis specials resolve before generic deltas when needed
	if id == "push-promo":
		_resolve_push_promo(act)
	elif id == "interview-round":
		_resolve_interview(act)
	elif id == "accept-hop":
		if not _accept_pending_offer(act):
			return false
	elif id == "decline-hop":
		_decline_pending_offer(act)
	elif id in LaborMarketData.CRISIS_ACTIVITY_IDS:
		_resolve_crisis_choice(id, act)
	else:
		var deltas: Dictionary = act.get("deltas", {})
		_apply_deltas(deltas)
		last_activity_id = id
		last_activity_title = str(act.get("title", ""))
		var use_n := int(activity_use_counts.get(id, 0))
		last_month_flavour = ActivitiesData.pick_flavour(act, use_n)
		last_deltas = deltas.duplicate(true)
		_apply_performance_from_activity(act)
		_apply_hunt_from_activity(id, act)

	months_played += 1
	tenure_months += 1
	if on_probation:
		probation_months_left = maxi(probation_months_left - 1, 0)
		if probation_months_left <= 0:
			on_probation = false
			last_probation_ended = true

	_tick_labor_climate()
	_tick_company_state()
	# Layoff drama only if not already resolving a crisis choice this month
	if id not in LaborMarketData.CRISIS_ACTIVITY_IDS:
		_roll_layoff_drama()

	var skip_ev := id in ["accept-hop", "decline-hop"] or id in LaborMarketData.CRISIS_ACTIVITY_IDS
	if roll_event and not skip_ev:
		_roll_and_apply_event()
	else:
		_clear_event()
	last_performance_delta = performance - perf_before
	last_salary_before = sal_before
	last_salary_delta = salary_num - sal_before
	activity_use_counts[id] = int(activity_use_counts.get(id, 0)) + 1
	last_salary_hold_reason = "" if last_salary_delta != 0 else _compute_salary_hold_reason()
	return true


## Optional side visit on the city/company map (1× per planning month).
func apply_map_visit(location_id: String) -> bool:
	if job_id == "":
		return false
	if map_used_this_month:
		return false
	var loc: Dictionary = MapData.get_location(location_id)
	if loc.is_empty():
		return false
	var seed_key := year * 1000 + month * 19 + months_played * 41 + hash(location_id)
	var ev: Dictionary = MapData.roll_for_location(location_id, seed_key)
	if ev.is_empty():
		return false
	var ed: Dictionary = ev.get("deltas", {})
	_apply_deltas(ed)
	map_used_this_month = true
	last_map_location_id = location_id
	last_map_location_title = str(loc.get("title", ""))
	last_map_event_id = str(ev.get("id", ""))
	last_map_event_title = str(ev.get("title", ""))
	last_map_event_flavour = str(ev.get("flavour", ""))
	last_map_deltas = ed.duplicate(true)
	# Career side-effects
	if location_id == "company":
		performance = clampi(performance + 3, 0, 100)
	elif location_id == "job-board":
		var gain := int(round(12 * LaborMarketData.hunt_mult(market_climate)))
		hunt_progress = clampi(hunt_progress + maxi(gain, 4), 0, 100)
		if hunt_progress >= 55 and pending_offer.is_empty() and posmod(seed_key, 2) == 0:
			_generate_pending_offer(seed_key + 7)
			last_map_event_flavour += "\n\n（求職進度上升——似有 Offer 嗅味。）"
	return true


func _compute_salary_hold_reason() -> String:
	## Truthful early-game copy: salary only moves via push-promo (or hop).
	var needed := CompaniesData.promo_tenure_needed(job_level)
	if on_probation:
		return "人工未變——仍在試用期（剩 %d 月）。轉正後再夠年資（%s 約 %d 個月）先可用「爭取升職／加薪」。" % [
			probation_months_left, CompaniesData.level_label(job_level), needed
		]
	if last_probation_ended:
		var left := maxi(needed - tenure_months, 0)
		if left > 0:
			return "人工未變——剛轉正；內部調薪／升職要夠年資（尚約 %d 月）同績效，再用「爭取升職／加薪」。" % left
		return "人工未變——剛轉正；下次可用「爭取升職／加薪」搏調薪（績效門檻約 %d）。" % CompaniesData.RAISE_PERF
	if tenure_months < needed:
		return "人工未變——年資未夠內部調薪窗口（而家 %d／門檻 %d 個月）。績效夠之後用「爭取升職／加薪」。" % [
			tenure_months, needed
		]
	if performance < CompaniesData.RAISE_PERF:
		return "人工未變——績效未到調薪門檻（而家 %d／≥%d）。繼續做好本業，再用「爭取升職／加薪」。" % [
			performance, CompaniesData.RAISE_PERF
		]
	if last_career_kind == "freeze":
		return "人工未變——爭取未批，叫你再等個季度。下季可再試「爭取升職／加薪」。"
	if last_career_kind == "pip":
		return "人工未變——考核警告／凍薪風險；先拉返績效同健康。"
	return "人工未變——今個月冇走「爭取升職／加薪」；年資同績效已達門檻，下個月可以試。"


func can_push_promo() -> bool:
	if job_id == "" or job_level == "manager":
		return false
	if pending_offer.size() > 0:
		return false
	if tenure_months < CompaniesData.promo_tenure_needed(job_level):
		return false
	if performance < CompaniesData.RAISE_PERF:
		return false
	if health < 30:
		return false
	return true


func has_pending_offer() -> bool:
	return not pending_offer.is_empty()


## Smoke / debug only: advance N planning months applying activities in cycle.
func fast_forward_months(count: int, activity_cycle: Array = []) -> Dictionary:
	var summary := {
		"months": 0,
		"events": 0,
		"seasons_seen": {},
		"activities": [],
		"company_states": {},
		"climates": {},
		"crises": 0,
		"promos": 0,
		"hops": 0,
	}
	if job_id == "":
		return summary
	var ids: Array = activity_cycle
	if ids.is_empty():
		ids = ActivitiesData.activity_ids()
	if ids.is_empty():
		return summary
	for i in range(count):
		var aid := str(ids[i % ids.size()])
		# Crisis month: only crisis choices
		if crisis_active:
			aid = str(LaborMarketData.CRISIS_ACTIVITY_IDS[i % LaborMarketData.CRISIS_ACTIVITY_IDS.size()])
		# Prefer promo / hop when eligible during FF
		elif can_push_promo() and i % 5 == 4:
			aid = "push-promo"
		elif has_pending_offer() and i % 7 == 3:
			aid = "accept-hop"
		elif hunt_progress >= 50 and i % 6 == 2 and not has_pending_offer():
			aid = "interview-round"
		var season := season_id()
		summary["seasons_seen"][season] = int(summary["seasons_seen"].get(season, 0)) + 1
		var before_level := job_level
		var before_co := company_id
		if not apply_activity(aid, true):
			# fallback to safe activity
			if not apply_activity("deep-rest", true):
				break
			aid = "deep-rest"
		summary["months"] = int(summary["months"]) + 1
		summary["activities"].append(aid)
		summary["company_states"][company_state] = int(summary["company_states"].get(company_state, 0)) + 1
		summary["climates"][market_climate] = int(summary["climates"].get(market_climate, 0)) + 1
		if last_crisis_kind != "":
			summary["crises"] = int(summary["crises"]) + 1
		if last_event_id != "":
			summary["events"] = int(summary["events"]) + 1
		if last_career_kind == "promo" or (job_level != before_level and last_career_kind == "raise"):
			if last_career_kind == "promo":
				summary["promos"] = int(summary["promos"]) + 1
		if company_id != before_co:
			summary["hops"] = int(summary["hops"]) + 1
		prepare_next_month()
	return summary


func to_save_dict() -> Dictionary:
	return {
		"education_id": education_id,
		"job_id": job_id,
		"company_name": company_name,
		"company_id": company_id,
		"company_state": company_state,
		"salary": salary,
		"salary_num": salary_num,
		"track": track,
		"job_title": job_title,
		"job_level": job_level,
		"infra": infra,
		"app": app,
		"manage": manage,
		"influence": influence,
		"health": health,
		"year": year,
		"month": month,
		"months_played": months_played,
		"tenure_months": tenure_months,
		"performance": performance,
		"on_probation": on_probation,
		"probation_months_left": probation_months_left,
		"last_probation_ended": last_probation_ended,
		"hunt_progress": hunt_progress,
		"pending_offer": pending_offer.duplicate(true),
		"last_month_flavour": last_month_flavour,
		"last_activity_id": last_activity_id,
		"last_activity_title": last_activity_title,
		"last_deltas": last_deltas.duplicate(true),
		"last_performance_delta": last_performance_delta,
		"last_salary_delta": last_salary_delta,
		"last_salary_before": last_salary_before,
		"last_salary_hold_reason": last_salary_hold_reason,
		"activity_use_counts": activity_use_counts.duplicate(true),
		"last_event_id": last_event_id,
		"last_event_title": last_event_title,
		"last_event_flavour": last_event_flavour,
		"last_event_deltas": last_event_deltas.duplicate(true),
		"map_used_this_month": map_used_this_month,
		"last_map_location_id": last_map_location_id,
		"last_map_location_title": last_map_location_title,
		"last_map_event_id": last_map_event_id,
		"last_map_event_title": last_map_event_title,
		"last_map_event_flavour": last_map_event_flavour,
		"last_map_deltas": last_map_deltas.duplicate(true),
		"last_company_state": last_company_state,
		"last_company_changed": last_company_changed,
		"last_company_flavour": last_company_flavour,
		"last_career_kind": last_career_kind,
		"last_career_title": last_career_title,
		"last_career_flavour": last_career_flavour,
		"market_climate": market_climate,
		"last_climate_changed": last_climate_changed,
		"last_climate_flavour": last_climate_flavour,
		"crisis_active": crisis_active,
		"crisis_kind": crisis_kind,
		"forced_job_hunt": forced_job_hunt,
		"last_crisis_kind": last_crisis_kind,
		"last_crisis_title": last_crisis_title,
		"last_crisis_flavour": last_crisis_flavour,
	}


func apply_save_dict(d: Dictionary) -> void:
	education_id = str(d.get("education_id", ""))
	job_id = str(d.get("job_id", ""))
	company_name = str(d.get("company_name", ""))
	company_id = str(d.get("company_id", ""))
	company_state = str(d.get("company_state", "stable"))
	if company_id == "" and job_id != "":
		company_id = CompaniesData.resolve_company_id_from_job(current_job())
	salary = str(d.get("salary", ""))
	salary_num = int(d.get("salary_num", 0))
	if salary_num <= 0 and salary != "":
		salary_num = CompaniesData.parse_salary_mid(salary)
	track = str(d.get("track", ""))
	job_title = str(d.get("job_title", ""))
	job_level = str(d.get("job_level", "junior"))
	infra = int(d.get("infra", 0))
	app = int(d.get("app", 0))
	manage = int(d.get("manage", 0))
	influence = int(d.get("influence", 0))
	health = int(d.get("health", 100))
	year = int(d.get("year", 1))
	month = int(d.get("month", 1))
	months_played = int(d.get("months_played", 0))
	tenure_months = int(d.get("tenure_months", months_played))
	performance = int(d.get("performance", 50))
	on_probation = bool(d.get("on_probation", false))
	probation_months_left = int(d.get("probation_months_left", 0))
	last_probation_ended = bool(d.get("last_probation_ended", false))
	hunt_progress = int(d.get("hunt_progress", 0))
	pending_offer = (d.get("pending_offer", {}) as Dictionary).duplicate(true)
	last_month_flavour = str(d.get("last_month_flavour", ""))
	last_activity_id = str(d.get("last_activity_id", ""))
	last_activity_title = str(d.get("last_activity_title", ""))
	last_deltas = (d.get("last_deltas", {}) as Dictionary).duplicate(true)
	last_performance_delta = int(d.get("last_performance_delta", 0))
	last_salary_delta = int(d.get("last_salary_delta", 0))
	last_salary_before = int(d.get("last_salary_before", 0))
	last_salary_hold_reason = str(d.get("last_salary_hold_reason", ""))
	var _auc = d.get("activity_use_counts", {})
	activity_use_counts = _auc.duplicate(true) if typeof(_auc) == TYPE_DICTIONARY else {}
	last_event_id = str(d.get("last_event_id", ""))
	last_event_title = str(d.get("last_event_title", ""))
	last_event_flavour = str(d.get("last_event_flavour", ""))
	last_event_deltas = (d.get("last_event_deltas", {}) as Dictionary).duplicate(true)
	map_used_this_month = bool(d.get("map_used_this_month", false))
	last_map_location_id = str(d.get("last_map_location_id", ""))
	last_map_location_title = str(d.get("last_map_location_title", ""))
	last_map_event_id = str(d.get("last_map_event_id", ""))
	last_map_event_title = str(d.get("last_map_event_title", ""))
	last_map_event_flavour = str(d.get("last_map_event_flavour", ""))
	last_map_deltas = (d.get("last_map_deltas", {}) as Dictionary).duplicate(true)
	last_company_state = str(d.get("last_company_state", company_state))
	last_company_changed = bool(d.get("last_company_changed", false))
	last_company_flavour = str(d.get("last_company_flavour", ""))
	last_career_kind = str(d.get("last_career_kind", ""))
	last_career_title = str(d.get("last_career_title", ""))
	last_career_flavour = str(d.get("last_career_flavour", ""))
	market_climate = str(d.get("market_climate", "balanced"))
	if not LaborMarketData.is_valid(market_climate):
		market_climate = "balanced"
	last_climate_changed = bool(d.get("last_climate_changed", false))
	last_climate_flavour = str(d.get("last_climate_flavour", ""))
	crisis_active = bool(d.get("crisis_active", false))
	crisis_kind = str(d.get("crisis_kind", ""))
	forced_job_hunt = bool(d.get("forced_job_hunt", false))
	last_crisis_kind = str(d.get("last_crisis_kind", ""))
	last_crisis_title = str(d.get("last_crisis_title", ""))
	last_crisis_flavour = str(d.get("last_crisis_flavour", ""))
	_clamp_stats()
	performance = clampi(performance, 0, 100)
	hunt_progress = clampi(hunt_progress, 0, 100)


func _resolve_push_promo(act: Dictionary) -> void:
	var deltas: Dictionary = act.get("deltas", {})
	_apply_deltas(deltas)
	last_activity_id = "push-promo"
	last_activity_title = str(act.get("title", "爭取升職／加薪"))
	last_deltas = deltas.duplicate(true)
	performance = clampi(performance + 4, 0, 100)

	var needed := CompaniesData.promo_tenure_needed(job_level)
	var can_level := job_level != "manager" and tenure_months >= needed and performance >= CompaniesData.PROMO_PERF and health >= 35
	var company_ok := company_state != "shrinking"
	if company_state == "expanding":
		can_level = can_level  # easier flavour only
	elif company_state == "acquired":
		can_level = can_level and performance >= CompaniesData.PROMO_PERF + 5
	elif not company_ok:
		can_level = false

	var seed_key := year * 1000 + month * 29 + tenure_months * 7 + performance
	var roll := posmod(seed_key, 100)

	if can_level and roll < performance:
		var old_title := job_title
		var old_sal := salary_num
		job_level = CompaniesData.next_level(job_level)
		job_title = CompaniesData.title_for(track, job_level)
		salary_num = int(round(salary_num * 1.14 / 500.0) * 500)
		salary = CompaniesData.format_salary(salary_num)
		performance = clampi(performance - 12, 40, 100)
		influence = clampi(influence + 5, 0, 100)
		manage = clampi(manage + 2, 0, 100)
		last_career_kind = "promo"
		last_career_title = "升職成功"
		last_career_flavour = "你由 %s 升到 %s，月薪 HK$%s → HK$%s。Team 茶水間傳開——「今次輪到你」。" % [
			old_title, job_title, CompaniesData.format_salary(old_sal), salary
		]
		last_month_flavour = last_career_flavour
	elif performance >= CompaniesData.RAISE_PERF and company_state != "shrinking" and roll < performance + 15:
		var old_sal2 := salary_num
		salary_num = int(round(salary_num * 1.06 / 500.0) * 500)
		salary = CompaniesData.format_salary(salary_num)
		performance = clampi(performance - 5, 35, 100)
		last_career_kind = "raise"
		last_career_title = "加薪（未升職）"
		last_career_flavour = "升職未批，但 HR 批咗加薪：HK$%s → HK$%s。你咬咬牙，繼續喺位打。" % [
			CompaniesData.format_salary(old_sal2), salary
		]
		last_month_flavour = last_career_flavour
	elif performance < CompaniesData.PIP_PERF or (health < 35 and performance < 50):
		last_career_kind = "pip"
		last_career_title = "考核警告／凍薪風險"
		last_career_flavour = "一對一時空氣冷。對方講「要見改善」——績效同健康都拉警報。今個月無升無加，只有 PIP 陰影。"
		last_month_flavour = last_career_flavour
		performance = clampi(performance - 3, 0, 100)
	else:
		last_career_kind = "freeze"
		last_career_title = "未批——再等個季度"
		last_career_flavour = str(act.get("flavour", "爭取未果。Headcount 凍住，叫你下季再傾。"))
		last_month_flavour = last_career_flavour


func _resolve_interview(act: Dictionary) -> void:
	var deltas: Dictionary = act.get("deltas", {})
	_apply_deltas(deltas)
	last_activity_id = "interview-round"
	last_activity_title = str(act.get("title", "面試衝刺"))
	last_deltas = deltas.duplicate(true)
	last_month_flavour = str(act.get("flavour", ""))
	hunt_progress = clampi(hunt_progress + 20, 0, 100)
	performance = clampi(performance - 1, 0, 100)  # distracted
	var seed_key := year * 777 + month * 31 + hunt_progress * 13 + influence
	if hunt_progress >= 45 and pending_offer.is_empty():
		_generate_pending_offer(seed_key)
		last_career_kind = "offer"
		last_career_title = "收到外部 Offer"
		last_career_flavour = str(pending_offer.get("flavour", "有 Offer。"))
		last_month_flavour = last_career_flavour
	elif not pending_offer.is_empty():
		last_career_kind = "offer"
		last_career_title = "Offer 仍有效"
		last_career_flavour = str(pending_offer.get("flavour", ""))
	else:
		last_career_kind = ""
		last_career_title = ""
		last_career_flavour = ""


func _accept_pending_offer(act: Dictionary) -> bool:
	if pending_offer.is_empty():
		return false
	var off: Dictionary = pending_offer.duplicate(true)
	var old_co := company_name
	company_id = str(off.get("company_id", company_id))
	var co: Dictionary = CompaniesData.get_company(company_id)
	company_name = str(off.get("company_name", CompaniesData.company_name(company_id)))
	company_state = str(co.get("start_state", "stable"))
	track = str(off.get("track", track))
	job_level = str(off.get("job_level", job_level))
	job_title = str(off.get("job_title", CompaniesData.title_for(track, job_level)))
	salary_num = int(off.get("salary_num", salary_num))
	salary = CompaniesData.format_salary(salary_num)
	# job_id becomes synthetic hop id (keep education)
	job_id = "hop-%s-%s" % [company_id, job_level]
	tenure_months = 0
	influence = clampi(influence - 12, 0, 100)
	performance = 50
	on_probation = true
	probation_months_left = 3
	last_probation_ended = false
	hunt_progress = 0
	pending_offer = {}
	var deltas: Dictionary = act.get("deltas", {"health": -2, "manage": 1})
	_apply_deltas(deltas)
	last_activity_id = "accept-hop"
	last_activity_title = str(act.get("title", "接受跳槽"))
	last_deltas = deltas.duplicate(true)
	last_career_kind = "hop"
	last_career_title = "跳槽成功"
	last_career_flavour = "你辭別 %s，過檔去 %s 做 %s（HK$%s）。年資歸零、人情淡咗一截，試用期三個月——新章開始。" % [
		old_co, company_name, job_title, salary
	]
	last_month_flavour = last_career_flavour
	last_company_state = company_state
	last_company_changed = true
	last_company_flavour = "入職新公司：%s" % CompaniesData.state_flavour(company_state)
	return true


func _decline_pending_offer(act: Dictionary) -> void:
	var deltas: Dictionary = act.get("deltas", {})
	_apply_deltas(deltas)
	last_activity_id = "decline-hop"
	last_activity_title = str(act.get("title", "拒絕 Offer"))
	last_deltas = deltas.duplicate(true)
	pending_offer = {}
	hunt_progress = clampi(hunt_progress - 10, 0, 100)
	performance = clampi(performance + 2, 0, 100)
	last_career_kind = "decline"
	last_career_title = "留低現職"
	last_career_flavour = str(act.get("flavour", "你拒絕咗外部 Offer，決定再喺現職搏一舖。"))
	last_month_flavour = last_career_flavour


func _generate_pending_offer(seed_key: int) -> void:
	var stats := stats_dict()
	stats["salary_num"] = salary_num
	pending_offer = CompaniesData.generate_offer(stats, track, job_level, company_id, seed_key, market_climate)


func _apply_performance_from_activity(act: Dictionary) -> void:
	var bias := str(act.get("bias", ""))
	var delta := 2
	if bias == track:
		delta = 7
	elif bias == "manage":
		delta = 5
	elif bias == "social":
		delta = 3
	elif bias == "study":
		delta = 3
	elif bias == "rest":
		delta = -2
	elif bias == "career":
		delta = 1
	if company_state == "expanding" and bias == track:
		delta += 2
	elif company_state == "shrinking":
		delta -= 1
	performance = clampi(performance + delta, 0, 100)


func _apply_hunt_from_activity(id: String, act: Dictionary) -> void:
	var bias := str(act.get("bias", ""))
	var base := 0
	if id == "update-cv":
		base = 18
	elif id == "job-apply":
		base = 28
	elif bias == "career":
		base = 8
	# Shrinking company nudges people to look
	if company_state == "shrinking" and bias != "rest":
		base += 3
	if forced_job_hunt and bias == "career":
		base += 5
	if base > 0:
		var gain := int(round(base * LaborMarketData.hunt_mult(market_climate)))
		hunt_progress = clampi(hunt_progress + maxi(gain, 1), 0, 100)


func _tick_company_state() -> void:
	var prev := company_state
	var seed_key := year * 10000 + month * 97 + months_played * 13 + hash(company_id) + tenure_months
	var nxt := CompaniesData.roll_next_state(company_id, company_state, season_id(), seed_key, market_climate)
	# Soft stickiness: only accept change ~35% unless shrinking pressure
	var stick := posmod(seed_key * 3 + 11, 100)
	if nxt != prev:
		var chance := 35
		if prev == "stable" and nxt == "expanding" and season_id() == "spring":
			chance = 55
		if season_id() == "winter" and nxt in ["shrinking", "acquired"]:
			chance = 50
		if market_climate == "freezing" and nxt == "shrinking":
			chance = 55
		if stick >= chance:
			nxt = prev
	company_state = nxt
	last_company_state = company_state
	last_company_changed = company_state != prev
	if last_company_changed:
		last_company_flavour = "公司動態：由「%s」→「%s」。%s" % [
			CompaniesData.state_label(prev),
			CompaniesData.state_label(company_state),
			CompaniesData.state_flavour(company_state)
		]
	else:
		# Unchanged: keep short/rotated line for resolve collapse (UI may chip it)
		var seed_key2 := year * 100 + month * 11 + months_played
		last_company_flavour = CompaniesData.state_flavour(company_state, seed_key2)



func _tick_labor_climate() -> void:
	var prev := market_climate
	var seed_key := year * 9001 + month * 131 + months_played * 17 + hash(company_id)
	var nxt := LaborMarketData.roll_next_climate(market_climate, season_id(), seed_key)
	market_climate = nxt
	last_climate_changed = market_climate != prev
	if last_climate_changed:
		last_climate_flavour = "市況：由「%s」→「%s」。%s" % [
			LaborMarketData.label(prev),
			LaborMarketData.label(market_climate),
			LaborMarketData.resolve_flavour(market_climate)
		]
	else:
		last_climate_flavour = LaborMarketData.resolve_flavour(market_climate)


func _roll_layoff_drama() -> void:
	## Soft outcomes apply immediately; severe sets crisis_active for next hub month.
	if company_state != "shrinking":
		_clear_crisis_result()
		return
	# Already in an unresolved crisis month — don't stack / wipe flavour
	if crisis_active:
		return
	_clear_crisis_result()
	var newly := last_company_changed and company_state == "shrinking"
	var seed_key := year * 5003 + month * 71 + months_played * 19 + performance + hash(company_id)
	# Not every shrinking month fires drama (~55% newly, ~32% ongoing)
	var fire_roll := posmod(seed_key, 100)
	var need := 45 if newly else 68
	if market_climate == "freezing":
		need -= 12
	elif market_climate == "booming":
		need += 8
	if fire_roll >= need:
		return
	var kind := LaborMarketData.roll_crisis_kind(newly, market_climate, performance, seed_key + 3)
	var deltas: Dictionary = LaborMarketData.crisis_immediate_deltas(kind)
	_apply_deltas(deltas)
	last_crisis_kind = kind
	last_crisis_title = LaborMarketData.crisis_title(kind)
	last_crisis_flavour = LaborMarketData.crisis_flavour(kind)
	if kind == "pip":
		performance = clampi(performance - 6, 0, 100)
	elif kind == "freeze":
		performance = clampi(performance - 2, 0, 100)
	elif kind == "rumor":
		hunt_progress = clampi(hunt_progress + int(round(6 * LaborMarketData.hunt_mult(market_climate))), 0, 100)
	elif kind == "forced_hunt":
		forced_job_hunt = true
		hunt_progress = clampi(hunt_progress + int(round(10 * LaborMarketData.hunt_mult(market_climate))), 0, 100)
	if LaborMarketData.crisis_is_severe(kind):
		crisis_active = true
		crisis_kind = kind
		last_crisis_flavour += "\n\n（下個月計劃被危機選項鎖定：留低搏／接受遣散／立刻投履歷。）"


func _resolve_crisis_choice(id: String, act: Dictionary) -> void:
	var deltas: Dictionary = act.get("deltas", {})
	_apply_deltas(deltas)
	last_activity_id = id
	last_activity_title = str(act.get("title", ""))
	last_deltas = deltas.duplicate(true)
	last_month_flavour = str(act.get("flavour", ""))
	performance = clampi(performance - 2, 0, 100)
	match id:
		"crisis-stay":
			var seed_key := year * 111 + month * 13 + performance
			if performance >= 70 and posmod(seed_key, 100) < 40:
				company_state = "stable"
				last_company_changed = true
				last_company_flavour = "你搏留成功：公司暫時企穩（「穩定」）。%s" % CompaniesData.state_flavour("stable")
			else:
				performance = clampi(performance + 3, 0, 100)
			forced_job_hunt = false
			last_career_kind = "crisis-stay"
			last_career_title = "危機抉擇・留低搏"
			last_career_flavour = last_month_flavour
		"crisis-severance":
			forced_job_hunt = true
			hunt_progress = clampi(hunt_progress + int(round(35 * LaborMarketData.hunt_mult(market_climate))), 0, 100)
			influence = clampi(influence - 6, 0, 100)
			last_career_kind = "crisis-severance"
			last_career_title = "危機抉擇・接受遣散"
			last_career_flavour = last_month_flavour + "\n\n（求職進度大增；你已進入強制搵工狀態。）"
			company_state = "shrinking"
		"crisis-hunt-now":
			forced_job_hunt = true
			hunt_progress = clampi(hunt_progress + int(round(40 * LaborMarketData.hunt_mult(market_climate))), 0, 100)
			last_career_kind = "crisis-hunt"
			last_career_title = "危機抉擇・立刻求職"
			last_career_flavour = last_month_flavour
			var seed2 := year * 777 + month * 31 + hunt_progress * 13 + influence
			if hunt_progress >= 40 and pending_offer.is_empty():
				_generate_pending_offer(seed2)
				if has_pending_offer():
					last_career_flavour += "\n\n" + str(pending_offer.get("flavour", ""))
	crisis_active = false
	crisis_kind = ""
	last_crisis_kind = id
	last_crisis_title = last_career_title
	last_crisis_flavour = last_career_flavour


func _clear_market_crisis() -> void:
	market_climate = "balanced"
	last_climate_changed = false
	last_climate_flavour = ""
	crisis_active = false
	crisis_kind = ""
	forced_job_hunt = false
	_clear_crisis_result()


func _clear_crisis_result() -> void:
	last_crisis_kind = ""
	last_crisis_title = ""
	last_crisis_flavour = ""


func _roll_and_apply_event() -> void:
	var seed_key := year * 1000 + month * 17 + months_played * 31 + hash(last_activity_id)
	var ev: Dictionary = EventsData.roll_event(season_id(), seed_key, 70)
	if ev.is_empty():
		_clear_event()
		return
	var ed: Dictionary = ev.get("deltas", {})
	_apply_deltas(ed)
	last_event_id = str(ev.get("id", ""))
	last_event_title = str(ev.get("title", ""))
	last_event_flavour = str(ev.get("flavour", ""))
	last_event_deltas = ed.duplicate(true)
	# Event tags can nudge performance lightly
	var eid := last_event_id
	if eid in ["layoff-rumor", "acquisition-rumor"]:
		performance = clampi(performance - 2, 0, 100)
		hunt_progress = clampi(hunt_progress + 5, 0, 100)


func _clear_event() -> void:
	last_event_id = ""
	last_event_title = ""
	last_event_flavour = ""
	last_event_deltas = {}


func _clear_map_result() -> void:
	last_map_location_id = ""
	last_map_location_title = ""
	last_map_event_id = ""
	last_map_event_title = ""
	last_map_event_flavour = ""
	last_map_deltas = {}


func _clear_career_result() -> void:
	last_career_kind = ""
	last_career_title = ""
	last_career_flavour = ""


func _apply_deltas(deltas: Dictionary) -> void:
	infra += int(deltas.get("infra", 0))
	app += int(deltas.get("app", 0))
	manage += int(deltas.get("manage", 0))
	influence += int(deltas.get("influence", 0))
	health += int(deltas.get("health", 0))
	_clamp_stats()


func _clamp_stats() -> void:
	infra = clampi(infra, 0, 100)
	app = clampi(app, 0, 100)
	manage = clampi(manage, 0, 100)
	influence = clampi(influence, 0, 100)
	health = clampi(health, 0, 100)


func stats_dict() -> Dictionary:
	return {
		"infra": infra,
		"app": app,
		"manage": manage,
		"influence": influence,
		"health": health
	}
