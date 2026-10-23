class_name CompaniesData
extends RefCounted
## Phase 5 — 虛構雇主模板＋公司狀態機＋職級／職稱（禁真實商標）


const STATES := ["expanding", "stable", "acquired", "shrinking"]

const LEVELS := ["junior", "mid", "senior", "lead", "manager"]

## Tenure months required to push next level (from current).
const PROMO_TENURE := {
	"junior": 6,
	"mid": 9,
	"senior": 12,
	"lead": 18,
	"manager": 999
}

const PROMO_PERF := 70
const RAISE_PERF := 58
const PIP_PERF := 32

const COMPANIES := {
	"peninsula-msp": {
		"id": "peninsula-msp",
		"name": "半島 MSP（虛構）",
		"sector": "msp",
		"sector_label": "MSP／外判支援",
		"base_stability": 55,
		"start_state": "stable"
	},
	"harbour-retail": {
		"id": "harbour-retail",
		"name": "港灣零售 IT（虛構）",
		"sector": "retail",
		"sector_label": "零售 IT",
		"base_stability": 58,
		"start_state": "stable"
	},
	"seaside-finance": {
		"id": "seaside-finance",
		"name": "海旁金融 IT（虛構）",
		"sector": "finance",
		"sector_label": "金融 IT",
		"base_stability": 72,
		"start_state": "stable"
	},
	"civic-outsource": {
		"id": "civic-outsource",
		"name": "公民系統外判（虛構）",
		"sector": "gov-outsource",
		"sector_label": "政府相關外判",
		"base_stability": 66,
		"start_state": "stable"
	},
	"codeup-startup": {
		"id": "codeup-startup",
		"name": "灣仔初創「碼上」（虛構）",
		"sector": "startup",
		"sector_label": "初創",
		"base_stability": 32,
		"start_state": "expanding"
	},
	"central-enterprise": {
		"id": "central-enterprise",
		"name": "中環企業數碼部（虛構）",
		"sector": "enterprise",
		"sector_label": "大型企業",
		"base_stability": 78,
		"start_state": "stable"
	},
}

## Fallback when a job string cannot be mapped.
const DEFAULT_COMPANY_ID := "central-enterprise"

const STATE_LABELS := {
	"expanding": "擴充中",
	"stable": "穩定",
	"acquired": "被收購整合中",
	"shrinking": "大幅收縮／執笠風險"
}

const STATE_FLAVOUR := {
	"expanding": "公司擴充：招人、新專案、坑位多——加班亦可能多。",
	"stable": "公司穩定：日常運維為主，少大起大落。",
	"acquired": "公司被收購：整合、重複崗位、新文化——留任定走未定。",
	"shrinking": "公司大幅收縮：預算凍、傳聞裁員——宜睇路。"
}


static func all_ids() -> Array:
	return COMPANIES.keys()


static func get_company(id: String) -> Dictionary:
	if COMPANIES.has(id):
		return COMPANIES[id].duplicate(true)
	return {}


static func company_name(id: String) -> String:
	var c := get_company(id)
	return str(c.get("name", "未知公司"))


static func state_label(state: String) -> String:
	return str(STATE_LABELS.get(state, state))


static func state_flavour(state: String) -> String:
	return str(STATE_FLAVOUR.get(state, ""))


static func resolve_company_id_from_job(job: Dictionary) -> String:
	var cid := str(job.get("company_id", ""))
	if COMPANIES.has(cid):
		return cid
	# Legacy name fuzzy map
	var nm := str(job.get("company", ""))
	if "半島" in nm or "MSP" in nm:
		return "peninsula-msp"
	if "港灣" in nm or "零售" in nm:
		return "harbour-retail"
	if "海旁" in nm or "金融" in nm or "銀行" in nm:
		return "seaside-finance"
	if "公民" in nm or "物流" in nm or "外判" in nm:
		return "civic-outsource"
	if "碼上" in nm or "初創" in nm:
		return "codeup-startup"
	if "中環" in nm or "數碼港" in nm or "雲服務" in nm or "企業" in nm:
		return "central-enterprise"
	if "雲港" in nm or "數據中心" in nm:
		return "peninsula-msp"
	return DEFAULT_COMPANY_ID


static func level_index(level: String) -> int:
	var i := LEVELS.find(level)
	return i if i >= 0 else 0


static func next_level(level: String) -> String:
	var i := level_index(level)
	if i >= LEVELS.size() - 1:
		return level
	return str(LEVELS[i + 1])


static func level_label(level: String) -> String:
	match level:
		"junior":
			return "Junior"
		"mid":
			return "Mid"
		"senior":
			return "Senior"
		"lead":
			return "Lead"
		"manager":
			return "Manager"
		_:
			return level


static func title_for(track: String, level: String) -> String:
	var t := track if track in ["infra", "app"] else "app"
	match level:
		"junior":
			return "Junior Sysadmin" if t == "infra" else "Junior Developer"
		"mid":
			return "Sysadmin" if t == "infra" else "Developer"
		"senior":
			return "Senior Sysadmin" if t == "infra" else "Senior Developer"
		"lead":
			return "Infra Lead" if t == "infra" else "Tech Lead"
		"manager":
			return "Infra Manager" if t == "infra" else "Engineering Manager"
		_:
			return "IT Specialist"


static func parse_salary_mid(salary_str: String) -> int:
	## "20,000–24,000" or "20000-24000" → midpoint
	var cleaned := salary_str.replace(",", "").replace(" ", "").replace("–", "-").replace("—", "-")
	var parts := cleaned.split("-")
	if parts.size() >= 2:
		var a := int(parts[0])
		var b := int(parts[1])
		if a > 0 and b > 0:
			return int((a + b) / 2.0)
	var n := int(cleaned)
	return n if n > 0 else 18000


static func format_salary(num: int) -> String:
	var s := str(maxi(num, 0))
	var out := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			out = "," + out
		out = s[i] + out
		count += 1
	return out


static func promo_tenure_needed(level: String) -> int:
	return int(PROMO_TENURE.get(level, 12))


## Weighted next state. seed_key deterministic for smoke.
## climate (Phase 5.x): booming↓shrinking / freezing↑shrinking.
static func roll_next_state(company_id: String, current: String, season: String, seed_key: int, climate: String = "balanced") -> String:
	var c := get_company(company_id)
	var stab := int(c.get("base_stability", 50))
	var cur := current if current in STATES else "stable"
	# Weight table: [expanding, stable, acquired, shrinking]
	var w := [10, 50, 5, 8]
	match cur:
		"expanding":
			w = [35, 40, 8, 12]
		"stable":
			w = [18, 55, 8, 12]
		"acquired":
			w = [5, 25, 40, 25]
		"shrinking":
			w = [8, 22, 10, 50]
	# Stability bias
	if stab >= 70:
		w[0] += 8
		w[1] += 10
		w[3] = maxi(w[3] - 8, 2)
	elif stab <= 40:
		w[0] = maxi(w[0] - 6, 2)
		w[3] += 14
		w[2] += 4
	# Season
	match season:
		"spring":
			w[0] += 12  # FY hiring
		"summer":
			w[1] += 6
		"autumn":
			w[2] += 6  # deal season whispers
		"winter":
			w[3] += 10
			w[2] += 6
	# Labor market climate (5.x)
	w[0] += LaborMarketData.expand_bias(climate)
	w[3] += LaborMarketData.shrink_bias(climate)
	w[0] = maxi(w[0], 2)
	w[3] = maxi(w[3], 2)
	var total := 0
	for x in w:
		total += int(x)
	if total <= 0:
		return cur
	var roll := posmod(seed_key * 1103515245 + 12345, total)
	var acc := 0
	for i in range(STATES.size()):
		acc += int(w[i])
		if roll < acc:
			return str(STATES[i])
	return cur


## Build an external offer from player stats.
static func generate_offer(gs_stats: Dictionary, track: String, level: String, current_company_id: String, seed_key: int, climate: String = "balanced") -> Dictionary:
	var ids: Array = []
	for cid in all_ids():
		if str(cid) != current_company_id:
			ids.append(str(cid))
	if ids.is_empty():
		ids = all_ids()
	var pick := str(ids[posmod(seed_key, ids.size())])
	var co := get_company(pick)
	var lvl_i := level_index(level)
	# Often hop up one band if stats strong
	var tech := int(gs_stats.get("infra" if track == "infra" else "app", 0))
	var infl := int(gs_stats.get("influence", 0))
	var new_lvl := level
	if tech >= 45 and infl >= 25 and lvl_i < LEVELS.size() - 1:
		if posmod(seed_key, 3) != 0:
			new_lvl = next_level(level)
	elif tech >= 60 and lvl_i < LEVELS.size() - 2:
		new_lvl = next_level(next_level(level)) if lvl_i + 2 < LEVELS.size() else next_level(level)
	var base_sal := int(gs_stats.get("salary_num", 20000))
	var bump := 1.08 + (infl / 500.0) + (tech / 800.0)
	if new_lvl != level:
		bump += 0.10
	# Stability of target nudges pay
	var stab := int(co.get("base_stability", 50))
	if stab < 40:
		bump += 0.06  # startup risk premium
	elif stab > 70:
		bump -= 0.02
	bump += LaborMarketData.offer_bump_extra(climate)
	var new_sal := int(round(base_sal * bump / 500.0) * 500)
	new_sal = maxi(new_sal, base_sal + 1000)
	return {
		"company_id": pick,
		"company_name": str(co.get("name", "")),
		"track": track,
		"job_level": new_lvl,
		"job_title": title_for(track, new_lvl),
		"salary_num": new_sal,
		"salary": format_salary(new_sal),
		"flavour": "外部 Offer（市況「%s」）：%s 請你做 %s，月薪約 HK$%s。跳槽會重置年資、流失部分人情，並進入試用期。" % [
			LaborMarketData.label(climate), str(co.get("name", "")), title_for(track, new_lvl), format_salary(new_sal)
		]
	}
