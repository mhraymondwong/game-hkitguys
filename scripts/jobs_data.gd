class_name JobsData
extends RefCounted
## Port of simple/index.html EDU + JOBS tables (zh-Hant)

const EDU := {
	"diploma": {
		"id": "diploma",
		"title": "綜合畢業",
		"desc": "高文憑／副學士／IVE 等實務路徑。入行偏支援同運維，腳踏實地，學得快。"
	},
	"uni": {
		"id": "uni",
		"title": "大學畢業",
		"desc": "學士學位。開發／雲／分析門檻較易開，起薪帶通常略高一截。"
	}
}

const JOBS := {
	"diploma": [
		{
			"id": "helpdesk",
			"title": "Helpdesk 技術員",
			"track": "infra",
			"salary": "14,000–16,500",
			"company": "半島 MSP（虛構）",
			"company_id": "peninsula-msp",
			"stats": {"infra": 28, "app": 12, "manage": 8, "influence": 10, "health": 78},
			"flavour": "第一個月：電話響過不停，password reset 做到手軟。茶餐廳午餐聽前輩講「慢慢學，唔好死火。」你搞掂咗第一張 P1 ticket。"
		},
		{
			"id": "desktop",
			"title": "Desktop Support",
			"track": "infra",
			"salary": "15,000–17,000",
			"company": "港灣零售 IT（虛構）",
			"company_id": "harbour-retail",
			"stats": {"infra": 30, "app": 10, "manage": 6, "influence": 8, "health": 74},
			"flavour": "第一個月：落 spot 裝機、執線、教阿姐用新 POS。返工袋永遠有幾條 HDMI。你開始認得邊條樓層 Wi‑Fi 最廢。"
		},
		{
			"id": "noc",
			"title": "NOC 值班員",
			"track": "infra",
			"salary": "15,500–18,000",
			"company": "雲港數據中心（虛構）",
			"company_id": "peninsula-msp",
			"stats": {"infra": 32, "app": 8, "manage": 5, "influence": 6, "health": 68},
			"flavour": "第一個月：夜更螢幕藍光映住面。警報一響心跳加速——結果係 false positive。前輩話：「歡迎嚟 Infra，瞓得好係奢侈。」"
		},
		{
			"id": "sysadmin-jr",
			"title": "Sysadmin Junior",
			"track": "infra",
			"salary": "16,000–18,500",
			"company": "海旁金融 IT 外判（虛構）",
			"company_id": "seaside-finance",
			"stats": {"infra": 34, "app": 14, "manage": 8, "influence": 10, "health": 72},
			"flavour": "第一個月：跟住 patch、backup、睇 monitoring。你第一次改 production change，手震但成功。Team lead 請咗杯凍檸茶。"
		},
		{
			"id": "app-support",
			"title": "Application Support",
			"track": "app",
			"salary": "15,000–17,500",
			"company": "城中物流系統部（虛構）",
			"company_id": "civic-outsource",
			"stats": {"infra": 14, "app": 28, "manage": 10, "influence": 12, "health": 76},
			"flavour": "第一個月：用戶話「個系統死咗」——多數係 cache。你學識用 log 同溫柔語氣安撫業務。第一單 UAT 終於過數。"
		},
		{
			"id": "junior-dev-dip",
			"title": "Junior Developer",
			"track": "app",
			"salary": "16,500–19,000",
			"company": "灣仔初創「碼上」（虛構）",
			"company_id": "codeup-startup",
			"stats": {"infra": 10, "app": 32, "manage": 6, "influence": 8, "health": 70},
			"flavour": "第一個月：第一個 PR 被人 comment 到滿紅。你熬夜改完，merge 嗰刻好似黄昏天空咁亮。綜合畢業入開發，你覺得自己要再勁啲。"
		}
	],
	"uni": [
		{
			"id": "helpdesk-uni",
			"title": "Helpdesk 技術員",
			"track": "infra",
			"salary": "15,000–17,000",
			"company": "半島 MSP（虛構）",
			"company_id": "peninsula-msp",
			"stats": {"infra": 26, "app": 14, "manage": 10, "influence": 14, "health": 80},
			"flavour": "第一個月：學位入 Helpdesk，有人笑你「屈就」。你反而學識基層 ticket 先至係根。第一個月績效唔錯，人話你可以轉組。"
		},
		{
			"id": "sysadmin-uni",
			"title": "Sysadmin Junior",
			"track": "infra",
			"salary": "18,000–21,000",
			"company": "海旁金融 IT（虛構）",
			"company_id": "seaside-finance",
			"stats": {"infra": 36, "app": 16, "manage": 10, "influence": 14, "health": 74},
			"flavour": "第一個月：跟雲遷移小組做文件同小腳手。你第一次入機房，冷氣同心跳一齊凍。前輩話：「大學理論有用，但 production 唔會依書。」"
		},
		{
			"id": "cloud-trainee",
			"title": "Cloud／Infra Trainee",
			"track": "infra",
			"salary": "19,000–22,000",
			"company": "數碼港方向雲服務商（虛構）",
			"company_id": "central-enterprise",
			"stats": {"infra": 38, "app": 18, "manage": 8, "influence": 12, "health": 72},
			"flavour": "第一個月：IAM、VPC、監控 dashboard 塞滿腦。你搞掂第一個 staging 環境，夕陽透過玻璃幕牆打進來，好似開咗光柱。"
		},
		{
			"id": "junior-dev",
			"title": "Junior Developer",
			"track": "app",
			"salary": "20,000–24,000",
			"company": "中環企業數碼部（虛構）",
			"company_id": "central-enterprise",
			"stats": {"infra": 12, "app": 38, "manage": 8, "influence": 12, "health": 72},
			"flavour": "第一個月：sprint 節奏趕過港鐵。你交咗第一個小 feature，QA 打回頭兩次。站會上你終於敢開波講 blocker。"
		},
		{
			"id": "ba-junior",
			"title": "BA Junior／系統分析見習",
			"track": "app",
			"salary": "18,500–22,000",
			"company": "九龍銀行科技夥伴（虛構）",
			"company_id": "seaside-finance",
			"stats": {"infra": 10, "app": 30, "manage": 16, "influence": 20, "health": 76},
			"flavour": "第一個月：會議多過 code。你寫第一份 BRD，被業務改到面目全非。你開始明白：聽人講需求，同聽得明，係兩件事。"
		},
		{
			"id": "app-support-uni",
			"title": "Application Support",
			"track": "app",
			"salary": "17,000–20,000",
			"company": "城中物流系統部（虛構）",
			"company_id": "civic-outsource",
			"stats": {"infra": 14, "app": 30, "manage": 12, "influence": 16, "health": 78},
			"flavour": "第一個月：跟 release、睇 error log、教用戶。你用學位背景寫咗份簡易 runbook，team 話「終於有人肯寫低」。"
		}
	]
}


static func education_ids() -> Array:
	return ["diploma", "uni"]


static func get_education(edu_id: String) -> Dictionary:
	return EDU.get(edu_id, {})


static func jobs_for_education(edu_id: String) -> Array:
	var list: Variant = JOBS.get(edu_id, [])
	if list is Array:
		return list
	return []


static func get_job(edu_id: String, job_id: String) -> Dictionary:
	for j in jobs_for_education(edu_id):
		if j is Dictionary and str(j.get("id", "")) == job_id:
			return j
	return {}


static func job_count(edu_id: String) -> int:
	return jobs_for_education(edu_id).size()
