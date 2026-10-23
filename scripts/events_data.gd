class_name EventsData
extends RefCounted
## 輕量每月隨機事件表（zh-Hant；輕粵語）
## 活動結算後可觸發；細 deltas；可按季節加權；含內容擴充包


const EVENTS := [
	{
		"id": "vendor-lunch",
		"title": "Vendor 請食飯",
		"flavour": "供應商約咗茶餐廳，塞咗兩張名片畀你。你記得邊個唔食香菜——人情帳又加一筆。",
		"deltas": {"influence": 2, "health": 1},
		"seasons": ["spring", "autumn"]
	},
	{
		"id": "slack-outage",
		"title": "Slack／Teams 全日掛",
		"flavour": "通訊工具掛咗，大家改用電話同走廊喊。你終於同隔籬位講咗超過三句說話。",
		"deltas": {"app": 1, "manage": 1, "health": -2},
		"seasons": ["summer", "autumn"]
	},
	{
		"id": "coffee-broke",
		"title": "咖啡機又壞",
		"flavour": "茶水間貼「Out of order」。成層樓靠便利店美式吊命，standup 人人眼腫。",
		"deltas": {"health": -1, "influence": 1},
		"seasons": ["spring", "summer", "autumn", "winter"]
	},
	{
		"id": "colleague-resign",
		"title": "同事遞信",
		"flavour": "隔籬位突然講下個月走。你幫佢 handover 半日，順便問清楚邊間工開幾多。",
		"deltas": {"influence": 2, "manage": 1, "health": -1},
		"seasons": ["winter", "spring"]
	},
	{
		"id": "standup-praise",
		"title": "Stand-up 被點名讚",
		"flavour": "Manager 當住眾人講你上個 change 好穩。你耳仔有啲熱，但 Slack 私訊嚟咗兩個 👍。",
		"deltas": {"influence": 3, "manage": 1},
		"seasons": ["spring", "summer", "autumn"]
	},
	{
		"id": "wrong-cab",
		"title": "Change 電郵搞錯 Window",
		"flavour": "有人將維護時段寫錯成上午。你及時叫停，CAB chat 炸咗一陣，事後大家話你眼利。",
		"deltas": {"infra": 1, "manage": 2, "health": -2},
		"seasons": ["autumn", "summer"]
	},
	{
		"id": "typhoon-signal",
		"title": "颱風波／八號風球",
		"flavour": "天文台升波，公司宣佈 WFH。你喺屋企對住不穩 VPN，反而第一次準時食晚飯。",
		"deltas": {"health": 3, "infra": 1},
		"seasons": ["summer"]
	},
	{
		"id": "audit-email",
		"title": "Audit 突擊電郵",
		"flavour": "內審半夜丟問卷過嚟。你翻舊 ticket 證明有跟流程，額角有啲汗。",
		"deltas": {"manage": 2, "infra": 1, "health": -2},
		"seasons": ["autumn"]
	},
	{
		"id": "yearend-party",
		"title": "尾牙／年終聚餐抽中獎",
		"flavour": "酒店球場好嘈。你抽中藍牙耳機，同平時唔傾偈嘅 VP 敬咗杯橙汁。",
		"deltas": {"influence": 2, "health": 2},
		"seasons": ["winter"]
	},
	{
		"id": "hiring-boom",
		"title": "部門突然開坑",
		"flavour": "財年一開，HR 狂貼 JD。你被拉去面試 junior，第一次坐喺面試官嗰邊。",
		"deltas": {"manage": 2, "influence": 1},
		"seasons": ["spring"]
	},
	{
		"id": "free-fruit",
		"title": "公司派水果／維他命",
		"flavour": "前台擺咗箱橙同維他命 C。大家笑話「健康福利」，但的確少咳兩日。",
		"deltas": {"health": 2},
		"seasons": ["winter", "spring"]
	},
	{
		"id": "monitor-false-alarm",
		"title": "監控誤報連環彈",
		"flavour": "Pager 響三次，原來係 threshold 設錯。你改完 rule，群組終於靜返。",
		"deltas": {"infra": 2, "health": -3},
		"seasons": ["summer", "autumn"]
	},
	# —— 內容擴充（港式職場插曲）——
	{
		"id": "layoff-rumor",
		"title": "裁員傳聞滿天飛",
		"flavour": "茶水間人人細聲講「聽講要瘦身」。HR 官方話冇呢回事，但 LinkedIn 突然多人更新 headline。",
		"deltas": {"influence": 2, "manage": 1, "health": -2},
		"seasons": ["winter", "autumn"]
	},
	{
		"id": "acquisition-rumor",
		"title": "傳被收購／合併",
		"flavour": "有人喺群組貼財經新聞截圖。老板叫大家「照常上班」。你開始備份自己寫過嘅文件。",
		"deltas": {"manage": 2, "influence": 1, "health": -1},
		"seasons": ["spring", "winter"]
	},
	{
		"id": "vpn-outage",
		"title": "全公司 VPN 掛網",
		"flavour": "朝早人人入唔到。IT 群組刷屏，有人改用手機熱點頂住。你幫隔籬位重裝客戶端，順便被人欠人情。",
		"deltas": {"infra": 2, "influence": 1, "health": -2},
		"seasons": ["summer", "autumn", "winter"]
	},
	{
		"id": "door-access-down",
		"title": "門禁壞咗成朝",
		"flavour": "大堂閘唔開，保安用手寫名簿放人。你第一次同平時唔打招呼嘅 VP 喺走廊排隊傾兩句。",
		"deltas": {"influence": 2, "health": 1},
		"seasons": ["spring", "summer", "autumn", "winter"]
	},
	{
		"id": "mtr-signal-fault",
		"title": "港鐵信號故障塞爆",
		"flavour": "月台人肉沙甸魚。你遲咗半小時，standup 改語音。老板都話「今日人人咁」。",
		"deltas": {"health": -2, "manage": 1},
		"seasons": ["summer", "autumn", "winter"]
	},
	{
		"id": "hackathon-poster",
		"title": "內部 Hackathon 海報",
		"flavour": "電梯貼滿「48 小時組隊」。有人拉你入組寫 frontend，你猶豫兩秒都係答咗。",
		"deltas": {"app": 1, "influence": 2},
		"seasons": ["spring", "autumn"]
	},
	{
		"id": "tea-room-news",
		"title": "茶水間新聞局",
		"flavour": "有人開住財經直播細聲講市況同邊間科技又裁。你學識邊啲傳聞可信、邊啲係吹水。",
		"deltas": {"influence": 2, "health": 1},
		"seasons": ["spring", "summer", "autumn", "winter"]
	},
	{
		"id": "cloud-bill-spike",
		"title": "雲帳單暴衝警報",
		"flavour": "FinOps 群組半夜 @channel。原來測試環境冇關。你幫手關機同寫 tag 政策，額角有汗。",
		"deltas": {"infra": 2, "manage": 2, "health": -2},
		"seasons": ["summer", "autumn"]
	},
]


static func all() -> Array:
	return EVENTS.duplicate(true)


static func get_event(id: String) -> Dictionary:
	for e in EVENTS:
		if str(e.get("id", "")) == id:
			return e.duplicate(true)
	return {}


static func event_ids() -> Array:
	var out: Array = []
	for e in EVENTS:
		out.append(str(e.get("id", "")))
	return out


## Season-weighted pool; empty season → all events.
static func events_for_season(season: String) -> Array:
	var preferred: Array = []
	var rest: Array = []
	for e in EVENTS:
		var seasons: Array = e.get("seasons", [])
		if season != "" and season in seasons:
			preferred.append(e.duplicate(true))
		else:
			rest.append(e.duplicate(true))
	if preferred.is_empty():
		return rest
	# Prefer seasonal 2:1 by duplicating preferred once in the roll pool conceptually;
	# callers should pick from preferred first.
	return preferred + rest


## Deterministic-ish pick for smoke: use seed_key hash. Chance ~70%.
static func roll_event(season: String, seed_key: int, chance_pct: int = 70) -> Dictionary:
	if chance_pct <= 0:
		return {}
	var roll := posmod(seed_key * 1103515245 + 12345, 100)
	if roll >= chance_pct:
		return {}
	var pool: Array = events_for_season(season)
	if pool.is_empty():
		pool = all()
	if pool.is_empty():
		return {}
	var idx := posmod(seed_key * 1664525 + 1013904223, pool.size())
	return pool[idx].duplicate(true)
