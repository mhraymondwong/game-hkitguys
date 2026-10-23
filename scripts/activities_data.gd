class_name ActivitiesData
extends RefCounted
## 月活動表（zh-Hant；輕粵語；autoload-free）
## 季節權重：港式春 3–5／夏 6–8／秋 9–11／冬 12–2；含內容擴充包


const ACTIVITIES := [
	{
		"id": "ticket-grind",
		"title": "清 Ticket 大作戰",
		"desc": "把頭先積壓嘅單清乾淨，幫同事收尾。",
		"bias": "infra",
		"deltas": {"infra": 4, "app": 1, "manage": 0, "influence": 1, "health": -4},
		"flavour": "ServiceNow 列表終於由紅變綠。你收工前搞掂最後一張 P2，前輩拍肩：「今個月靠你。」茶餐廳凍檸茶都甜咗少少。"
	},
	{
		"id": "oncall-night",
		"title": "On-call 夜更",
		"desc": "拎住 pager，半夜隨時要上線。",
		"bias": "infra",
		"deltas": {"infra": 5, "app": 0, "manage": 1, "influence": 2, "health": -8},
		"flavour": "凌晨三點警報響。你喺黑漆漆大廳開 VPN，原來係 monitoring 誤報——但你第一次獨立 close 咗一個 severity。天亮眼圈有啲重。"
	},
	{
		"id": "patch-window",
		"title": "Patch Window",
		"desc": "跟 change 流程打補丁、restart、驗收。",
		"bias": "infra",
		"deltas": {"infra": 5, "app": 1, "manage": 2, "influence": 1, "health": -5},
		"flavour": "Change CAB 過咗。你同值班一齊 countdown，patch 完 smoke test 全綠。Manager 喺 chat 打咗句「好嘢」。"
	},
	{
		"id": "feature-sprint",
		"title": "Feature Sprint",
		"desc": "跟 sprint 寫功能、開 PR、對齊設計。",
		"bias": "app",
		"deltas": {"infra": 0, "app": 5, "manage": 1, "influence": 1, "health": -5},
		"flavour": "Stand-up 每日都講 progress。你嘅 PR 終於 merge，staging 見到自己寫嘅 button。Slack 有人 react 🎉——細細嘅成就感。"
	},
	{
		"id": "bug-hunt",
		"title": "追 Bug 馬拉松",
		"desc": "跟 log、reproduce、寫 regression test。",
		"bias": "app",
		"deltas": {"infra": 1, "app": 5, "manage": 0, "influence": 1, "health": -6},
		"flavour": "個 bug 原來係 timezone。你寫咗測試鎖死佢，QA 話「終於再現得穩」。你對住螢幕苦笑：又學多一課。"
	},
	{
		"id": "uat-support",
		"title": "UAT 傍住業務",
		"desc": "陪用戶驗收、記缺陷、教操作。",
		"bias": "app",
		"deltas": {"infra": 0, "app": 3, "manage": 2, "influence": 3, "health": -3},
		"flavour": "會議室投影模糊，但你耐住性子帶阿姐行完流程。UAT sign-off 一簽，業務請咗杯手沖。影響力，原來由聽人講起。"
	},
	{
		"id": "cert-study",
		"title": "考證溫書月",
		"desc": "下班溫書、做 mock，衝一張證照。",
		"bias": "study",
		"deltas": {"infra": 2, "app": 2, "manage": 0, "influence": 1, "health": -4},
		"flavour": "港鐵上背 flashcard，週末圖書館坐到閉館。Mock 分數慢慢上。你未考到都覺得腦裡面多咗張地圖。"
	},
	{
		"id": "team-lunch",
		"title": "Team 午餐局",
		"desc": "約同事食飯，聽八卦、建人情。",
		"bias": "social",
		"deltas": {"infra": 0, "app": 0, "manage": 1, "influence": 4, "health": 2},
		"flavour": "茶餐廳拼枱，大家講邊間公司又裁員、邊個 manager 好傾。你記住幾個人名同忌口——職場人情，好多時由一碟乾炒牛河開始。"
	},
	{
		"id": "upward-chat",
		"title": "向上管理一杯咖啡",
		"desc": "約 skip-level／lead 傾進展同期望。",
		"bias": "manage",
		"deltas": {"infra": 0, "app": 0, "manage": 4, "influence": 3, "health": -1},
		"flavour": "Cafe 冷氣好猛。你準備好三點 update，對方反而問你想三年後做咩。你第一次覺得有人認真聽你講職涯。"
	},
	{
		"id": "deep-rest",
		"title": "認真放假充電",
		"desc": "少 OT、早瞓、行山或者淨係發夢。",
		"bias": "rest",
		"deltas": {"infra": 0, "app": 0, "manage": 0, "influence": 0, "health": 10},
		"flavour": "今個月你敢按「離開」準時。周末行咗大嶼山，手機靜音。返工一見螢幕仲係頭痛，但人已經返魂。"
	},
	{
		"id": "lab-sandbox",
		"title": "自己起 Lab",
		"desc": "家用舊機／雲免費額玩 sandbox。",
		"bias": "study",
		"deltas": {"infra": 3, "app": 3, "manage": 0, "influence": 0, "health": -3},
		"flavour": "半夜 docker compose up，炸咗兩次先掂。你截圖放 notes，心想：呢啲野面試一定有用——至少而家好玩。"
	},
	{
		"id": "war-room",
		"title": "War Room 救火",
		"desc": "生產出事，全組開橋、對客、事後檢討。",
		"bias": "infra",
		"deltas": {"infra": 3, "app": 3, "manage": 3, "influence": 2, "health": -10},
		"flavour": "War room 投影全紅。你負責記 timeline，有人喊、有人笑。事後 postmortem 你寫咗第一份，手仲震，但團隊記得你冇走。"
	},
	# —— Phase 3a 新增 ——
	{
		"id": "typhoon-wfh",
		"title": "颱風 WFH 維運",
		"desc": "打風在家盯系統、回 pager、保持服務。",
		"bias": "infra",
		"deltas": {"infra": 4, "app": 1, "manage": 1, "influence": 1, "health": -3},
		"flavour": "八號波，窗外橫風橫雨。你喺客廳摺枱開 laptop，VPN 斷斷續續都要 close 警報。屋企人煮咗碗麵放隔離——港式 on-call。"
	},
	{
		"id": "audit-prep",
		"title": "Audit／資安備戰",
		"desc": "整理證據、修 policy、陪內審行場。",
		"bias": "manage",
		"deltas": {"infra": 2, "app": 1, "manage": 4, "influence": 2, "health": -5},
		"flavour": "Excel 清單由 30 行變 300 行。內審問「邊度有簽核」，你翻出舊 email 截圖。過關嗰刻成組去茶水間透氣。"
	},
	{
		"id": "bonus-talk",
		"title": "年終 Bonus／評核月",
		"desc": "寫 self-review、對齊目標、談期望。",
		"bias": "manage",
		"deltas": {"infra": 0, "app": 0, "manage": 3, "influence": 4, "health": -2},
		"flavour": "Self-review 寫咗三版。一對一時你鼓起勇氣講貢獻，對方點頭記低。Bonus 未知數，但你覺得自己終於識講數。"
	},
	{
		"id": "meetup-night",
		"title": "Tech Meetup 晚上去",
		"desc": "聽分享、交換名片、擴人脈。",
		"bias": "social",
		"deltas": {"infra": 1, "app": 1, "manage": 0, "influence": 4, "health": -2},
		"flavour": "觀塘工業大廈冷氣猛。講者講 observability，你加咗三個 LinkedIn。散場茶餐廳繼續吹水到尾班車。"
	},
	{
		"id": "ransomware-drill",
		"title": "Ransomware Drill",
		"desc": "跟 tabletop／還原演練，練應變。",
		"bias": "infra",
		"deltas": {"infra": 4, "app": 2, "manage": 2, "influence": 1, "health": -6},
		"flavour": "桌上演習假設備份中招。你負責念 runbook，發現有一步過時。事後更新文件，保安同事比咗個讚。"
	},
	{
		"id": "side-project",
		"title": "週末 Side Project",
		"desc": "自己寫小工具／portfolio 作品。",
		"bias": "study",
		"deltas": {"infra": 1, "app": 4, "manage": 0, "influence": 1, "health": -3},
		"flavour": "GitHub 小 repo 終於有 README。你部署上免費額，傳畀朋友試。未必轉工用得着，但手感返嚟。"
	},
	{
		"id": "mentor-junior",
		"title": "帶 Junior／Buddy",
		"desc": "教新人、review 代碼、陪頭兩週。",
		"bias": "manage",
		"deltas": {"infra": 1, "app": 1, "manage": 4, "influence": 3, "health": -3},
		"flavour": "新人問嘅問題你三年前都問過。你畫咗張圖解釋 ticket 流程，對方眼燈亮咗。原來教人，自己都溫故。"
	},
	{
		"id": "vendor-poc",
		"title": "Vendor PoC 試用",
		"desc": "睇 demo、試工具、寫比較表。",
		"bias": "app",
		"deltas": {"infra": 1, "app": 3, "manage": 2, "influence": 2, "health": -3},
		"flavour": "三間 vendor 簡報好似複製貼上。你默默開表打分，最後推薦嗰間真係少踩坑。採購之後請你飲咖啡。"
	},
	# —— 內容擴充（港式職場）——
	{
		"id": "mtr-overtime",
		"title": "尾班車 OT 月",
		"desc": "趕尾班車返屋企，連續OT收尾。",
		"bias": "infra",
		"deltas": {"infra": 4, "app": 2, "manage": 1, "influence": 1, "health": -9},
		"flavour": "月台廣播「尾班車即將開出」。你揹住公司袋衝閘，耳機仲播緊 monitoring。返到屋企鞋都唔想除——港鐵同 ticket，一樣趕。"
	},
	{
		"id": "cha-chaan-teng-round",
		"title": "茶餐廳午後局長",
		"desc": "約同事去茶餐廳慢食、聽行內八卦。",
		"bias": "social",
		"deltas": {"infra": 0, "app": 0, "manage": 1, "influence": 5, "health": 3},
		"flavour": "凍柠茶撞奶。阿姐講邊間又傳裁、邊個跳去銀行。你記低忌口同人面——好多情報唔喺 Slack，喺乾炒牛河。"
	},
	{
		"id": "morning-daily",
		"title": "晨會 Daily 馬拉松",
		"desc": "日日 standup、更新板、對齊阻滯。",
		"bias": "manage",
		"deltas": {"infra": 1, "app": 2, "manage": 4, "influence": 2, "health": -4},
		"flavour": "「有冇 blocker？」問咗二十日。你開始識用三十秒講清進度，又幫人 unblock。板靚咗，聲帶有啲乾。"
	},
	{
		"id": "cloud-migration",
		"title": "上雲／搬遷專案",
		"desc": "搬 workload、切流量、盯成本同延遲。",
		"bias": "infra",
		"deltas": {"infra": 6, "app": 2, "manage": 2, "influence": 1, "health": -7},
		"flavour": "藍綠部署倒數。DNS 切過去嗰秒你屏住氣——latency 正常，帳單暫時未爆炸。群組先敢打「切完」。"
	},
	{
		"id": "hackathon-blitz",
		"title": "內部 Hackathon",
		"desc": "週末組隊做 prototype、簡報、搶內部獎。",
		"bias": "app",
		"deltas": {"infra": 1, "app": 5, "manage": 1, "influence": 3, "health": -6},
		"flavour": "四十八小時、三個披薩盒。你嘅 demo 勉強跑得動，評審笑住問「可不可以上 prod」。未必得，但人脈同信心都升咗。"
	},
	{
		"id": "perf-review-week",
		"title": "績效評核週",
		"desc": "寫貢獻、對齊目標、一對一談期望。",
		"bias": "manage",
		"deltas": {"infra": 0, "app": 0, "manage": 5, "influence": 3, "health": -3},
		"flavour": "表上要填「影響面」。你翻舊 PR 同 postmortem，第一次用數字講自己。評級未出，但你覺得講得出口。"
	},
	{
		"id": "vpn-firefight",
		"title": "VPN／遙距救火",
		"desc": "遙距掛、證書過期、人人喊入唔到。",
		"bias": "infra",
		"deltas": {"infra": 5, "app": 1, "manage": 2, "influence": 2, "health": -8},
		"flavour": "群組刷「VPN 掛咗」。你對住證書同 gateway 對咗成晚，終於有人話「入到」。茶水間之後當你半個英雄。"
	},
	{
		"id": "knowledge-base",
		"title": "補知識庫／Runbook",
		"desc": "寫文件、錄短片、清過時步驟。",
		"bias": "study",
		"deltas": {"infra": 2, "app": 2, "manage": 2, "influence": 2, "health": -2},
		"flavour": "舊 wiki 鏈結全紅。你重寫三篇 runbook，新人話「終於跟得明」。下一次 war room，大家開嘅係你篇。"
	},

	# —— Phase 5 職涯（內部／外部）——
	{
		"id": "push-promo",
		"title": "爭取升職／加薪",
		"desc": "準備材料、約一對一，內部爭取晉升或調薪。",
		"bias": "career",
		"deltas": {"infra": 0, "app": 0, "manage": 3, "influence": 2, "health": -3},
		"flavour": "你整理今季貢獻，約咗 lead 傾。結果未揭盅——升定加，定再等，下個月結算先知。"
	},
	{
		"id": "update-cv",
		"title": "更新履歷／LinkedIn",
		"desc": "改 CV、補項目、對外放出求職訊號。",
		"bias": "career",
		"deltas": {"infra": 0, "app": 1, "manage": 1, "influence": 2, "health": -1},
		"flavour": "你把 migration 同 war room 寫清楚啲。Headline 改完，quietly 打開「Open to work」。"
	},
	{
		"id": "job-apply",
		"title": "海投 JD",
		"desc": "篩 hybrid／on-call，投一輪合適職位。",
		"bias": "career",
		"deltas": {"infra": 0, "app": 0, "manage": 2, "influence": 1, "health": -3},
		"flavour": "投完二十封，有啲自動拒、有啲石沉大海。求職進度條喺心裡慢慢爬。"
	},
	{
		"id": "interview-round",
		"title": "面試衝刺",
		"desc": "準備行為題／技術題，走一輪面試。",
		"bias": "career",
		"deltas": {"infra": 1, "app": 1, "manage": 2, "influence": 2, "health": -5},
		"flavour": "白板題寫到手軟。完場你唔知表現點，但市況同身價，心裡有數。"
	},
	{
		"id": "accept-hop",
		"title": "接受跳槽 Offer",
		"desc": "辭職過檔——年資重置、試用期風險。",
		"bias": "career",
		"deltas": {"infra": 0, "app": 0, "manage": 1, "influence": -2, "health": -2},
		"flavour": "你簽咗新約。舊同事請食飯，新工卡未到——口袋裡係機遇同未知。"
	},
	{
		"id": "decline-hop",
		"title": "拒絕 Offer・留低",
		"desc": "外部 Offer 不接，繼續現職搏升遷。",
		"bias": "career",
		"deltas": {"infra": 0, "app": 0, "manage": 1, "influence": 1, "health": 1},
		"flavour": "你回「暫時留低」。Recruiter 嘆咗氣。你望住現職座位，決定再搏一季。"
	},

	# —— Phase 5.x 裁員／執笠危機月（嚴重時取代普通活動）——
	{
		"id": "crisis-stay",
		"title": "留低搏・收縮期求生",
		"desc": "唔走，繼續喺收縮公司搏留位——壓力大。",
		"bias": "career",
		"deltas": {"infra": 1, "app": 1, "manage": 2, "influence": -1, "health": -6},
		"flavour": "你決定留低。每天都係「會唔會叫到我名」嘅空氣。你加班證明價值，健康同人情都在流血。"
	},
	{
		"id": "crisis-severance",
		"title": "接受遣散方案",
		"desc": "簽方案、清位、拿補償——之後全力搵工。",
		"bias": "career",
		"deltas": {"infra": 0, "app": 0, "manage": 1, "influence": -4, "health": -4},
		"flavour": "你簽咗。工卡失效嗰刻，茶水間突然好靜。口袋裡係補償金同空白日曆——求職進度被迫拉滿。"
	},
	{
		"id": "crisis-hunt-now",
		"title": "立刻投履歷・走為上",
		"desc": "本月只做求職：海投、面試、卡住 Offer。",
		"bias": "career",
		"deltas": {"infra": 0, "app": 1, "manage": 2, "influence": 1, "health": -5},
		"flavour": "你冇再等傳聞落地。履歷連夜改、面試連軸轉。收縮公司後面，係市況同身價嘅賭博。"
	},
]


## Seasonal activity boosts (HK-ish workplace rhythm).
const SEASON_BOOST_IDS := {
	"spring": ["feature-sprint", "upward-chat", "mentor-junior", "team-lunch", "uat-support", "morning-daily", "hackathon-blitz", "push-promo"],
	"summer": ["oncall-night", "war-room", "typhoon-wfh", "ticket-grind", "ransomware-drill", "mtr-overtime", "vpn-firefight"],
	"autumn": ["audit-prep", "patch-window", "cert-study", "bug-hunt", "ransomware-drill", "perf-review-week", "cloud-migration"],
	"winter": ["deep-rest", "cert-study", "bonus-talk", "side-project", "meetup-night", "cha-chaan-teng-round", "knowledge-base", "update-cv", "job-apply", "interview-round"],
}


static func all() -> Array:
	return ACTIVITIES.duplicate(true)


static func get_activity(id: String) -> Dictionary:
	for a in ACTIVITIES:
		if str(a.get("id", "")) == id:
			return a.duplicate(true)
	return {}


static func activity_ids() -> Array:
	var out: Array = []
	for a in ACTIVITIES:
		out.append(str(a.get("id", "")))
	return out


## HK seasons from calendar month (1–12).
static func season_of_month(month: int) -> String:
	match clampi(month, 1, 12):
		3, 4, 5:
			return "spring"
		6, 7, 8:
			return "summer"
		9, 10, 11:
			return "autumn"
		_:
			return "winter"  # 12, 1, 2


static func season_label(season: String) -> String:
	match season:
		"spring":
			return "春"
		"summer":
			return "夏"
		"autumn":
			return "秋"
		"winter":
			return "冬"
		_:
			return season


static func season_label_full(season: String) -> String:
	match season:
		"spring":
			return "春季・財年／開坑"
		"summer":
			return "夏季・颱風／值班"
		"autumn":
			return "秋季・審計／資安"
		"winter":
			return "冬季・Bonus／充電"
		_:
			return season


static func season_boost_ids(season: String) -> Array:
	if SEASON_BOOST_IDS.has(season):
		return SEASON_BOOST_IDS[season].duplicate()
	return []


static func is_season_boosted(activity_id: String, month: int) -> bool:
	var season := season_of_month(month)
	return activity_id in season_boost_ids(season)


## Track-aware order: matching bias first, then study/social/rest/manage, then the rest.
static func activities_for_track(track: String) -> Array:
	var primary: Array = []
	var secondary: Array = []
	var rest: Array = []
	var soft := ["study", "social", "rest", "manage", "career"]
	for a in ACTIVITIES:
		var bias := str(a.get("bias", ""))
		if track != "" and bias == track:
			primary.append(a.duplicate(true))
		elif bias in soft:
			secondary.append(a.duplicate(true))
		else:
			rest.append(a.duplicate(true))
	return primary + secondary + rest


## Track + season: boosted seasonal activities rise within each band (★).
static func activities_for_track_season(track: String, month: int) -> Array:
	var base: Array = activities_for_track(track)
	var boosts: Array = season_boost_ids(season_of_month(month))
	var boosted: Array = []
	var normal: Array = []
	for a in base:
		var id := str(a.get("id", ""))
		var copy: Dictionary = a.duplicate(true)
		copy["season_boost"] = id in boosts
		if id in boosts:
			boosted.append(copy)
		else:
			normal.append(copy)
	return boosted + normal


static func bias_label(bias: String) -> String:
	match bias:
		"infra":
			return "Infra"
		"app":
			return "App"
		"manage":
			return "管理"
		"social":
			return "人脈"
		"study":
			return "學習"
		"rest":
			return "休息"
		"career":
			return "職涯"
		_:
			return bias


static func format_deltas(deltas: Dictionary) -> String:
	var parts: PackedStringArray = []
	var labels := {
		"infra": "Infra",
		"app": "App",
		"manage": "管理",
		"influence": "影響",
		"health": "健康"
	}
	for k in ["infra", "app", "manage", "influence", "health"]:
		var v := int(deltas.get(k, 0))
		if v == 0:
			continue
		var sign := "+" if v > 0 else ""
		parts.append("%s%s%s" % [sign, str(v), labels[k]])
	if parts.is_empty():
		return "無明顯變化"
	return "　".join(parts)
