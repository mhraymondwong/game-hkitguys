class_name MapData
extends RefCounted
## 城市／公司地圖地點＋短事件（港味；輕粵語）


const LOCATIONS := [
	{
		"id": "company",
		"title": "公司樓層",
		"desc": "Helpdesk／機房／開發位——返工日常。",
		"icon": "🏢"
	},
	{
		"id": "cha-chaan-teng",
		"title": "茶餐廳",
		"desc": "凍檸茶同人情帳。",
		"icon": "🍜"
	},
	{
		"id": "home",
		"title": "屋企",
		"desc": "港鐵夜歸之後，終於靜一靜。",
		"icon": "🏠"
	},
	{
		"id": "job-board",
		"title": "求職平台",
		"desc": "刷 JD、改 CV——睇市。",
		"icon": "💼"
	},
]

const EVENTS := [
	{
		"id": "floor-walk",
		"location": "company",
		"title": "巡層執 ticket",
		"flavour": "你行過 Helpdesk 同機房門口，幫人 reset 咗個密碼，順便聽聞有人要開新專案。",
		"deltas": {"infra": 1, "influence": 1}
	},
	{
		"id": "standup-corner",
		"location": "company",
		"title": "走廊 standup 偷聽",
		"flavour": "隔籬隊喺玻璃房對住 board 嗌。你記住兩個 blocker，返位寫低。",
		"deltas": {"app": 1, "manage": 1}
	},
	{
		"id": "boardroom-peek",
		"location": "company",
		"title": "Boardroom 門口擦過",
		"flavour": "門掩住，聽到「budget」同「headcount」。你加快腳步，但人脈雷達亮咗一下。",
		"deltas": {"influence": 2, "health": -1}
	},
	{
		"id": "milk-tea-gossip",
		"location": "cha-chaan-teng",
		"title": "凍檸茶八卦局",
		"flavour": "同事約咗楼下茶餐廳。話題由加班講到邊間又裁，你學識邊啲係吹水。",
		"deltas": {"influence": 2, "health": 1}
	},
	{
		"id": "set-lunch",
		"location": "cha-chaan-teng",
		"title": "常餐回血",
		"flavour": "番茄湯粗面配公仔麵煎蛋。胃暖咗，下午 standup 精神好啲。",
		"deltas": {"health": 3}
	},
	{
		"id": "vendor-card",
		"location": "cha-chaan-teng",
		"title": "Vendor 塞名片",
		"flavour": "供應商請你飲咖啡，塞咗張卡。你唔承諾，但記低佢負責邊個產品。",
		"deltas": {"influence": 1, "manage": 1}
	},
	{
		"id": "sofa-nap",
		"location": "home",
		"title": "沙發小瞓",
		"flavour": "踢完鞋就瞓咗半個鐘。電話靜音，世界暫時冇 Pager。",
		"deltas": {"health": 4, "influence": -1}
	},
	{
		"id": "side-learn",
		"location": "home",
		"title": "屋企惡補一課",
		"flavour": "你開住筆記重溫日頭睇唔完嘅 doc。貓行過鍵盤，你存低重點。",
		"deltas": {"app": 2, "infra": 1, "health": -1}
	},
	{
		"id": "family-call",
		"location": "home",
		"title": "打給屋企人",
		"flavour": "媽媽問你食咗未。你講咗兩句工作，多講咗幾句生活。",
		"deltas": {"health": 2, "influence": 1}
	},
	{
		"id": "jd-skim",
		"location": "job-board",
		"title": "刷一輪 JD",
		"flavour": "你篩咗「hybrid」「on-call」關鍵字。有啲薪水靚，有啲寫到好似要三個人做。",
		"deltas": {"influence": 1, "manage": 1}
	},
	{
		"id": "cv-tweak",
		"location": "job-board",
		"title": "改一版 CV",
		"flavour": "你把最近個 migration 寫清楚啲。LinkedIn 都順便更新 headline。",
		"deltas": {"influence": 2, "app": 1}
	},
	{
		"id": "recruiter-ping",
		"location": "job-board",
		"title": "Recruiter 私訊",
		"flavour": "有人問你方唔方便傾。你回「可睇 JD」，唔急應，但市況心裡有數。",
		"deltas": {"influence": 2, "health": -1}
	},
]


static func all_locations() -> Array:
	return LOCATIONS.duplicate(true)


static func get_location(id: String) -> Dictionary:
	for loc in LOCATIONS:
		if str(loc.get("id", "")) == id:
			return loc.duplicate(true)
	return {}


static func location_ids() -> Array:
	var out: Array = []
	for loc in LOCATIONS:
		out.append(str(loc.get("id", "")))
	return out


static func events_for_location(location_id: String) -> Array:
	var out: Array = []
	for e in EVENTS:
		if str(e.get("location", "")) == location_id:
			out.append(e.duplicate(true))
	return out


static func get_event(id: String) -> Dictionary:
	for e in EVENTS:
		if str(e.get("id", "")) == id:
			return e.duplicate(true)
	return {}


static func all_events() -> Array:
	return EVENTS.duplicate(true)


static func roll_for_location(location_id: String, seed_key: int) -> Dictionary:
	var pool: Array = events_for_location(location_id)
	if pool.is_empty():
		return {}
	var idx := posmod(seed_key * 1664525 + 1013904223, pool.size())
	return pool[idx].duplicate(true)


static func format_deltas(deltas: Dictionary) -> String:
	return ActivitiesData.format_deltas(deltas)
