class_name LaborMarketData
extends RefCounted
## Phase 5.x — 港式 IT 勞動市場景氣（booming / balanced / freezing）
## 規則（DESIGN）：
## - 春：財年招人味 → 偏 booming
## - 夏：相對穩定 → 黏住 balanced
## - 秋：預算／headcount 盤點 → 略偏 freezing
## - 冬：跳槽季＋景氣波動 → booming／freezing 雙向波動（唔黏太死）
## 影響：外部 Offer 質素、hunt_progress 增益、公司漂移向 shrinking 權重、hub 短文案（禁遊戲名）


const CLIMATES := ["booming", "balanced", "freezing"]

const LABELS := {
	"booming": "景氣旺",
	"balanced": "平穩",
	"freezing": "寒冬／凍招"
}

## Hub chrome 短句（唔印遊戲名）
const HUB_FLAVOUR := {
	"booming": "市面招人味濃——Offer 質素同求職進度都易啲上車。",
	"balanced": "市況唔旺唔淡；穩步為上，跳槽都要睇公司狀態。",
	"freezing": "凍招傳聞多——外部 Offer 縮水，公司收縮風險升。"
}

const RESOLVE_FLAVOUR := {
	"booming": "勞動市場：景氣旺。獵頭電話多，好崗位亦搶手。",
	"balanced": "勞動市場：平穩。有機會，但唔係人人有第二個 Offer。",
	"freezing": "勞動市場：寒冬。面試輪空多，凍薪凍招新聞滿天飛。"
}

## hunt_progress gain multiplier (basis points → float)
const HUNT_MULT := {
	"booming": 1.35,
	"balanced": 1.0,
	"freezing": 0.72
}

## Offer salary bump extra (additive on CompaniesData bump)
const OFFER_BUMP_EXTRA := {
	"booming": 0.06,
	"balanced": 0.0,
	"freezing": -0.05
}

## Extra weight on shrinking when rolling company next state
const SHRINK_WEIGHT_BIAS := {
	"booming": -6,
	"balanced": 0,
	"freezing": 12
}

## Extra weight on expanding
const EXPAND_WEIGHT_BIAS := {
	"booming": 10,
	"balanced": 0,
	"freezing": -4
}


static func is_valid(climate: String) -> bool:
	return climate in CLIMATES


static func label(climate: String) -> String:
	return str(LABELS.get(climate, climate))


static func hub_flavour(climate: String) -> String:
	return str(HUB_FLAVOUR.get(climate, ""))


static func resolve_flavour(climate: String) -> String:
	return str(RESOLVE_FLAVOUR.get(climate, ""))


static func hunt_mult(climate: String) -> float:
	return float(HUNT_MULT.get(climate, 1.0))


static func offer_bump_extra(climate: String) -> float:
	return float(OFFER_BUMP_EXTRA.get(climate, 0.0))


static func shrink_bias(climate: String) -> int:
	return int(SHRINK_WEIGHT_BIAS.get(climate, 0))


static func expand_bias(climate: String) -> int:
	return int(EXPAND_WEIGHT_BIAS.get(climate, 0))


## Deterministic climate drift. sticky ~55% unless winter volatility.
static func roll_next_climate(current: String, season: String, seed_key: int) -> String:
	var cur := current if is_valid(current) else "balanced"
	# Weights: [booming, balanced, freezing]
	var w := [20, 55, 25]
	match cur:
		"booming":
			w = [40, 40, 20]
		"balanced":
			w = [22, 52, 26]
		"freezing":
			w = [15, 40, 45]
	match season:
		"spring":
			w[0] += 18
			w[2] = maxi(w[2] - 8, 4)
		"summer":
			w[1] += 16
			w[0] = maxi(w[0] - 4, 6)
			w[2] = maxi(w[2] - 4, 6)
		"autumn":
			w[2] += 12
			w[0] = maxi(w[0] - 6, 5)
		"winter":
			# Hop season + volatility: push both extremes
			w[0] += 14
			w[2] += 14
			w[1] = maxi(w[1] - 10, 18)
	var total := 0
	for x in w:
		total += int(x)
	if total <= 0:
		return cur
	var roll := posmod(seed_key * 1664525 + 1013904223, total)
	var acc := 0
	var nxt := cur
	for i in range(CLIMATES.size()):
		acc += int(w[i])
		if roll < acc:
			nxt = str(CLIMATES[i])
			break
	# Stickiness
	var stick := posmod(seed_key * 7 + 3, 100)
	var chance := 42
	if season == "summer":
		chance = 28  # harder to leave balanced summer
	elif season == "winter":
		chance = 58  # more volatile
	elif season == "spring" and nxt == "booming":
		chance = 55
	elif season == "autumn" and nxt == "freezing":
		chance = 52
	if nxt != cur and stick >= chance:
		nxt = cur
	return nxt


## Soft / severe layoff drama kinds when company is shrinking.
const CRISIS_KINDS := ["pip", "freeze", "rumor", "severance", "forced_hunt"]

const CRISIS_TITLES := {
	"pip": "PIP 壓力／改善計劃",
	"freeze": "凍薪凍招・Headcount 凍住",
	"rumor": "茶水間執笠傳聞",
	"severance": "遣散方案上枱",
	"forced_hunt": "被迫全面求職"
}

const CRISIS_FLAVOUR := {
	"pip": "一對一空氣冷過冷氣。對方講「要見改善」——收縮期績效刀落得快。",
	"freeze": "加薪窗關死、HC 凍。Slack 靜到得見 bot。你望住年資，心裡計住後路。",
	"rumor": "茶餐廳有人講「下月執一隊」。無人證實，但健康同人情都削咗一截。",
	"severance": "HR 約你入房，桌上係方案摘要。留低搏、接受遣散、定即刻投履歷——呢個月冇普通日常。",
	"forced_hunt": "Team 解散味濃。Lead 暗示「早啲睇外面」。你被迫把求職當本月主業。"
}


static func crisis_title(kind: String) -> String:
	return str(CRISIS_TITLES.get(kind, kind))


static func crisis_flavour(kind: String) -> String:
	return str(CRISIS_FLAVOUR.get(kind, ""))


static func crisis_is_severe(kind: String) -> bool:
	return kind in ["severance", "forced_hunt"]


## Deltas applied immediately when crisis rolls (before player crisis choice).
static func crisis_immediate_deltas(kind: String) -> Dictionary:
	match kind:
		"pip":
			return {"health": -4, "influence": -2, "manage": 1}
		"freeze":
			return {"health": -2, "influence": -1}
		"rumor":
			return {"health": -5, "influence": -3}
		"severance":
			return {"health": -6, "influence": -2}
		"forced_hunt":
			return {"health": -3, "influence": -1, "manage": 1}
		_:
			return {"health": -2}


## Weighted crisis roll. Newly entered shrinking → higher severe chance.
static func roll_crisis_kind(newly_shrinking: bool, climate: String, performance: int, seed_key: int) -> String:
	# Weights aligned to CRISIS_KINDS order
	var w := [22, 22, 20, 18, 18]
	if newly_shrinking:
		w[3] += 10
		w[4] += 10
		w[0] += 4
	if climate == "freezing":
		w[3] += 8
		w[4] += 6
		w[1] += 4
	elif climate == "booming":
		w[4] += 6  # easier to hunt out
		w[3] = maxi(w[3] - 4, 6)
	if performance < 40:
		w[0] += 14
	elif performance >= 75:
		w[0] = maxi(w[0] - 8, 4)
		w[1] += 6
	var total := 0
	for x in w:
		total += int(x)
	var roll := posmod(seed_key * 48271 + 17, total)
	var acc := 0
	for i in range(CRISIS_KINDS.size()):
		acc += int(w[i])
		if roll < acc:
			return str(CRISIS_KINDS[i])
	return "rumor"


## Activity ids that replace normal hub list during severe crisis month.
const CRISIS_ACTIVITY_IDS := ["crisis-stay", "crisis-severance", "crisis-hunt-now"]
