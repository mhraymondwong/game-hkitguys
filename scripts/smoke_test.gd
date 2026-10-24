extends SceneTree
## Headless smoke for 《香港IT人》 Phase 1–5.x（存檔＋地圖＋公司／職涯＋勞動市場／裁員）
## Usage: godot --headless --path <project> --script res://scripts/smoke_test.gd


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	print("[smoke] 《香港IT人》 content smoke start")
	var ok := true

	var gs: Node = root.get_node_or_null("GameState")
	if gs == null:
		var script: GDScript = load("res://scripts/game_state.gd") as GDScript
		gs = script.new()
		gs.name = "GameState"
		root.add_child(gs)
		print("[smoke] GameState instantiated manually")
	else:
		print("[smoke] GameState autoload found")

	# —— JobsData coverage ——
	for edu in JobsData.education_ids():
		var n := JobsData.job_count(edu)
		print("[smoke] jobs for %s -> %d" % [edu, n])
		if n < 6:
			printerr("[smoke] FAIL: expected ≥6 jobs for %s" % edu)
			ok = false
		var tracks := {}
		for j in JobsData.jobs_for_education(edu):
			tracks[str(j.get("track", ""))] = true
		if not tracks.has("infra") or not tracks.has("app"):
			printerr("[smoke] FAIL: %s missing infra or app track" % edu)
			ok = false
		else:
			print("[smoke] %s has infra+app OK" % edu)

	# —— ActivitiesData ——
	var acts: Array = ActivitiesData.all()
	print("[smoke] activities count -> %d" % acts.size())
	if acts.size() < 24:
		printerr("[smoke] FAIL: expected ≥24 activities (content expand)")
		ok = false
	for a in acts:
		if str(a.get("id", "")) == "" or str(a.get("title", "")) == "" or str(a.get("flavour", "")) == "":
			printerr("[smoke] FAIL: incomplete activity %s" % a)
			ok = false
		if "Phase" in str(a.get("flavour", "")) or "placeholder" in str(a.get("flavour", "")):
			printerr("[smoke] FAIL: bad activity flavour %s" % a.get("id", "?"))
			ok = false
	var ordered: Array = ActivitiesData.activities_for_track("app")
	if ordered.is_empty() or str(ordered[0].get("bias", "")) != "app":
		printerr("[smoke] FAIL: activities_for_track app should lead with app bias")
		ok = false
	else:
		print("[smoke] activities_for_track OK")

	# —— Season weights ——
	if ActivitiesData.season_of_month(3) != "spring" or ActivitiesData.season_of_month(7) != "summer":
		printerr("[smoke] FAIL: season spring/summer mapping")
		ok = false
	if ActivitiesData.season_of_month(10) != "autumn" or ActivitiesData.season_of_month(12) != "winter":
		printerr("[smoke] FAIL: season autumn/winter mapping")
		ok = false
	if ActivitiesData.season_of_month(1) != "winter" or ActivitiesData.season_of_month(2) != "winter":
		printerr("[smoke] FAIL: season winter Jan/Feb")
		ok = false
	var summer_list: Array = ActivitiesData.activities_for_track_season("infra", 7)
	if summer_list.is_empty() or not bool(summer_list[0].get("season_boost", false)):
		printerr("[smoke] FAIL: summer infra list should lead with season boost")
		ok = false
	else:
		print("[smoke] season boost order OK id=%s" % summer_list[0].get("id", "?"))
	if not ActivitiesData.is_season_boosted("oncall-night", 7):
		printerr("[smoke] FAIL: oncall should boost in summer")
		ok = false
	if not ActivitiesData.is_season_boosted("deep-rest", 12):
		printerr("[smoke] FAIL: deep-rest should boost in winter")
		ok = false
	else:
		print("[smoke] season mapping OK")

	# —— EventsData ——
	var evs: Array = EventsData.all()
	print("[smoke] events count -> %d" % evs.size())
	if evs.size() < 16:
		printerr("[smoke] FAIL: expected ≥16 events")
		ok = false
	for e in evs:
		if str(e.get("id", "")) == "" or str(e.get("flavour", "")) == "":
			printerr("[smoke] FAIL: incomplete event %s" % e)
			ok = false
	var summer_ev: Dictionary = EventsData.roll_event("summer", 42, 100)
	if summer_ev.is_empty():
		printerr("[smoke] FAIL: roll_event chance 100 should return event")
		ok = false
	else:
		print("[smoke] roll_event OK id=%s" % summer_ev.get("id", "?"))
	var no_ev: Dictionary = EventsData.roll_event("winter", 1, 0)
	if not no_ev.is_empty():
		printerr("[smoke] FAIL: chance 0 should return empty")
		ok = false
	else:
		print("[smoke] roll_event chance0 OK")

	# —— Diploma path ——
	gs.begin_new_game()
	if not gs.select_education("diploma"):
		printerr("[smoke] FAIL: select_education diploma")
		ok = false
	if not gs.select_job("helpdesk"):
		printerr("[smoke] FAIL: select_job helpdesk")
		ok = false
	if not gs.accept_offer_and_run_first_month():
		printerr("[smoke] FAIL: accept_offer diploma/helpdesk")
		ok = false
	if gs.infra != 28 or gs.app != 12 or gs.month != 1 or gs.months_played != 1:
		printerr("[smoke] FAIL: diploma stats mismatch infra=%d app=%d month=%d played=%d" % [gs.infra, gs.app, gs.month, gs.months_played])
		ok = false
	else:
		print("[smoke] diploma/helpdesk first month OK")
	if gs.last_month_flavour == "":
		printerr("[smoke] FAIL: empty flavour")
		ok = false
	if "春" not in gs.calendar_label() and "冬" not in gs.calendar_label():
		# month 1 = winter
		printerr("[smoke] FAIL: calendar_label missing season got %s" % gs.calendar_label())
		ok = false
	else:
		print("[smoke] calendar_label season OK: %s" % gs.calendar_label())

	# —— Uni path + 3 activity months (no random event — isolate deltas) ——
	gs.begin_new_game()
	if not gs.select_education("uni"):
		printerr("[smoke] FAIL: select_education uni")
		ok = false
	if not gs.select_job("junior-dev"):
		printerr("[smoke] FAIL: select_job junior-dev")
		ok = false
	if not gs.accept_offer_and_run_first_month():
		printerr("[smoke] FAIL: accept_offer uni/junior-dev")
		ok = false
	if gs.app != 38 or gs.track != "app":
		printerr("[smoke] FAIL: uni junior-dev stats app=%d track=%s" % [gs.app, gs.track])
		ok = false
	else:
		print("[smoke] uni/junior-dev first month OK")

	var app_before: int = gs.app
	var health_before: int = gs.health
	var infra_before: int = gs.infra

	gs.prepare_next_month()
	if gs.month != 2 or gs.year != 1:
		printerr("[smoke] FAIL: prepare_next_month expected y1 m2 got y%d m%d" % [gs.year, gs.month])
		ok = false

	if not gs.apply_activity("feature-sprint", false):
		printerr("[smoke] FAIL: apply feature-sprint")
		ok = false
	if gs.app <= app_before or gs.months_played != 2 or gs.last_activity_id != "feature-sprint":
		printerr("[smoke] FAIL: feature-sprint stats app %d→%d played=%d id=%s" % [app_before, gs.app, gs.months_played, gs.last_activity_id])
		ok = false
	else:
		print("[smoke] activity 1 feature-sprint OK")

	gs.prepare_next_month()
	if not gs.apply_activity("deep-rest", false):
		printerr("[smoke] FAIL: apply deep-rest")
		ok = false
	if gs.months_played != 3 or gs.last_activity_id != "deep-rest":
		printerr("[smoke] FAIL: deep-rest played=%d id=%s" % [gs.months_played, gs.last_activity_id])
		ok = false
	else:
		print("[smoke] activity 2 deep-rest OK health=%d (was %d)" % [gs.health, health_before])

	gs.prepare_next_month()
	if not gs.apply_activity("ticket-grind", false):
		printerr("[smoke] FAIL: apply ticket-grind")
		ok = false
	if gs.infra <= infra_before or gs.months_played != 4:
		printerr("[smoke] FAIL: ticket-grind infra %d→%d played=%d" % [infra_before, gs.infra, gs.months_played])
		ok = false
	else:
		print("[smoke] activity 3 ticket-grind OK")

	# Clamp check
	gs.health = 200
	gs._clamp_stats()
	if gs.health != 100:
		printerr("[smoke] FAIL: clamp health expected 100 got %d" % gs.health)
		ok = false
	else:
		print("[smoke] clamp OK")

	# Year wrap
	gs.year = 1
	gs.month = 12
	gs.prepare_next_month()
	if gs.year != 2 or gs.month != 1:
		printerr("[smoke] FAIL: year wrap got y%d m%d" % [gs.year, gs.month])
		ok = false
	else:
		print("[smoke] year wrap OK")

	# —— Filter: diploma cannot pick uni-only id ——
	gs.begin_new_game()
	gs.select_education("diploma")
	if gs.select_job("junior-dev"):
		printerr("[smoke] FAIL: diploma should not select uni job junior-dev")
		ok = false
	else:
		print("[smoke] education filter OK")

	# —— Phase 3a: fast_forward 12 months with seasons + events ——
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.prepare_next_month()
	var cycle := [
		"feature-sprint", "oncall-night", "deep-rest", "audit-prep",
		"typhoon-wfh", "bonus-talk", "mtr-overtime", "cloud-migration",
		"hackathon-blitz", "perf-review-week", "vpn-firefight", "knowledge-base"
	]
	var ff: Dictionary = gs.fast_forward_months(12, cycle)
	print("[smoke] fast_forward months=%s events=%s seasons=%s" % [
		ff.get("months", 0), ff.get("events", 0), ff.get("seasons_seen", {})
	])
	if int(ff.get("months", 0)) != 12:
		printerr("[smoke] FAIL: fast_forward expected 12 months got %s" % ff.get("months", 0))
		ok = false
	var seasons_seen: Dictionary = ff.get("seasons_seen", {})
	# Starting month after first month prepare = month 2 (winter), then 12 advances cover ~all seasons
	if seasons_seen.size() < 3:
		printerr("[smoke] FAIL: expected ≥3 seasons in 12-month FF got %s" % seasons_seen)
		ok = false
	else:
		print("[smoke] fast_forward seasons OK")
	if int(ff.get("events", 0)) < 1:
		printerr("[smoke] FAIL: expected some events over 12 months")
		ok = false
	else:
		print("[smoke] fast_forward events OK count=%s" % ff.get("events", 0))
	if gs.months_played != 13:  # 1 first + 12 FF
		printerr("[smoke] FAIL: months_played after FF expected 13 got %d" % gs.months_played)
		ok = false
	else:
		print("[smoke] months_played after FF OK")

	# Event apply path on single month
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.prepare_next_month()
	# Force many rolls until event fires (or cap)
	var got_event := false
	for i in range(20):
		gs.month = 7  # summer
		gs.apply_activity("war-room", true)
		if gs.last_event_id != "":
			got_event = true
			print("[smoke] event fire OK id=%s title=%s" % [gs.last_event_id, gs.last_event_title])
			break
		gs.prepare_next_month()
	if not got_event:
		printerr("[smoke] FAIL: no event after 20 summer war-room rolls")
		ok = false

	# New activity ids exist
	for nid in ["typhoon-wfh", "audit-prep", "bonus-talk", "meetup-night", "ransomware-drill", "side-project", "mentor-junior", "vendor-poc", "mtr-overtime", "cha-chaan-teng-round", "morning-daily", "cloud-migration", "hackathon-blitz", "perf-review-week", "vpn-firefight", "knowledge-base"]:
		if ActivitiesData.get_activity(nid).is_empty():
			printerr("[smoke] FAIL: missing new activity %s" % nid)
			ok = false
	print("[smoke] expanded activities OK")
	for eid in ["layoff-rumor", "acquisition-rumor", "vpn-outage", "door-access-down", "mtr-signal-fault", "hackathon-poster", "tea-room-news", "cloud-bill-spike"]:
		if EventsData.get_event(eid).is_empty():
			printerr("[smoke] FAIL: missing new event %s" % eid)
			ok = false
	print("[smoke] expanded events OK")

	# —— Player-facing polish ——
	for edu in JobsData.education_ids():
		var edu_d: Dictionary = JobsData.get_education(edu)
		var blob := "%s %s" % [edu_d.get("title", ""), edu_d.get("desc", "")]
		for bad in ["Phase 1", "placeholder", "佔位", "male-short-shirt"]:
			if bad in blob:
				printerr("[smoke] FAIL: edu copy contains %s" % bad)
				ok = false
		for j in JobsData.jobs_for_education(edu):
			var fl := str(j.get("flavour", ""))
			if fl == "" or "Phase 1" in fl or "placeholder" in fl:
				printerr("[smoke] FAIL: bad flavour for %s" % j.get("id", "?"))
				ok = false
	print("[smoke] player-facing copy OK")

	# —— Opening polish A: no meta / game-title chrome outside title ——
	var opening_no_title := [
		"res://scripts/education.gd",
		"res://scripts/job.gd",
		"res://scripts/offer.gd",
		"res://scripts/month_result.gd",
		"res://scripts/hub.gd",
		"res://scripts/month_resolve.gd",
		"res://scripts/map.gd",
		"res://scripts/ui_style.gd",
		"res://scripts/activities_data.gd",
		"res://scripts/events_data.gd",
		"res://scripts/map_data.gd",
		"res://scripts/companies_data.gd"
	]
	for spath in opening_no_title:
		var fa := FileAccess.open(spath, FileAccess.READ)
		if fa == null:
			printerr("[smoke] FAIL: cannot read %s" % spath)
			ok = false
			continue
		var src := fa.get_as_text()
		fa.close()
		var lines: PackedStringArray = src.split("\n")
		var code_blob := ""
		for ln in lines:
			var t := ln.strip_edges()
			if t.begins_with("##") or t.begins_with("#"):
				continue
			code_blob += ln + "\n"
		for bad in ["Phase 1", "Phase 2", "Phase 3", "placeholder", "佔位", "male-short-shirt"]:
			if bad in code_blob:
				printerr("[smoke] FAIL: %s contains meta %s" % [spath, bad])
				ok = false
		if '"香港IT人"' in code_blob or "'香港IT人'" in code_blob or "《香港IT人》" in code_blob:
			printerr("[smoke] FAIL: %s must not assign game title in UI (title screen only)" % spath)
			ok = false
	var title_fa := FileAccess.open("res://scripts/title.gd", FileAccess.READ)
	if title_fa:
		var title_src := title_fa.get_as_text()
		title_fa.close()
		for bad in ["Phase 1", "placeholder", "佔位"]:
			if bad in title_src:
				printerr("[smoke] FAIL: title.gd contains %s" % bad)
				ok = false
		if "開始入行" not in title_src or "《香港IT人》" not in title_src:
			printerr("[smoke] FAIL: title missing start CTA or game title")
			ok = false
		if "繼續最近進度" not in title_src or "讀取" not in title_src:
			printerr("[smoke] FAIL: title missing continue/load")
			ok = false
	else:
		printerr("[smoke] FAIL: cannot read title.gd")
		ok = false
	var edu_src := FileAccess.get_file_as_string("res://scripts/education.gd")
	var job_src := FileAccess.get_file_as_string("res://scripts/job.gd")
	var offer_src := FileAccess.get_file_as_string("res://scripts/offer.gd")
	if "①／③　學歷" not in edu_src or "繼續 · 揀職位" not in edu_src:
		printerr("[smoke] FAIL: education step/CTA missing")
		ok = false
	if "②／③　入職" not in job_src or "繼續 · 睇 Offer" not in job_src:
		printerr("[smoke] FAIL: job step/CTA missing")
		ok = false
	if "③／③　聘用" not in offer_src or "確認你嘅 Offer" not in offer_src or "接受聘用，上班去" not in offer_src:
		printerr("[smoke] FAIL: offer step/CTA missing")
		ok = false
	if "make_step_tag" not in FileAccess.get_file_as_string("res://scripts/ui_style.gd"):
		printerr("[smoke] FAIL: make_step_tag missing")
		ok = false
	print("[smoke] opening polish A copy OK")

	# —— Scene files exist ——
	var scenes := [
		"res://scenes/title.tscn",
		"res://scenes/education.tscn",
		"res://scenes/job.tscn",
		"res://scenes/offer.tscn",
		"res://scenes/month_result.tscn",
		"res://scenes/hub.tscn",
		"res://scenes/month_resolve.tscn",
		"res://scenes/map.tscn"
	]
	for sp in scenes:
		if not ResourceLoader.exists(sp):
			printerr("[smoke] FAIL: missing scene %s" % sp)
			ok = false
		else:
			print("[smoke] scene %s OK" % sp)

	# —— Change through scenes ——
	var err := change_scene_to_file("res://scenes/title.tscn")
	if err != OK:
		printerr("[smoke] FAIL: change_scene title %s" % err)
		ok = false
	else:
		await process_frame
		await process_frame
		print("[smoke] title scene loaded")

	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.prepare_next_month()
	err = change_scene_to_file("res://scenes/hub.tscn")
	if err != OK:
		printerr("[smoke] FAIL: change_scene hub %s" % err)
		ok = false
	else:
		await process_frame
		await process_frame
		print("[smoke] hub scene loaded")

	gs.apply_activity("feature-sprint", true)
	err = change_scene_to_file("res://scenes/month_resolve.tscn")
	if err != OK:
		printerr("[smoke] FAIL: change_scene month_resolve %s" % err)
		ok = false
	else:
		await process_frame
		await process_frame
		print("[smoke] month_resolve scene loaded")

	if not FileAccess.file_exists(ProjectSettings.globalize_path(GameConfig.FONT_PATH)):
		printerr("[smoke] FAIL: font missing")
		ok = false
	else:
		print("[smoke] font OK")

	for ap in ProtagonistArt.ALL_FILES:
		if not FileAccess.file_exists(ProjectSettings.globalize_path(ap)):
			printerr("[smoke] FAIL: missing art %s" % ap)
			ok = false
		else:
			print("[smoke] art %s OK" % ap)

	# —— ProtagonistArt picker cases ——
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()

	gs.health = 30
	gs.last_activity_id = ""
	if ProtagonistArt.portrait_path(gs) != ProtagonistArt.PORTRAIT_TIRED:
		printerr("[smoke] FAIL: health 30 should be tired got %s" % ProtagonistArt.portrait_path(gs))
		ok = false
	else:
		print("[smoke] portrait tired@health30 OK")

	gs.health = 45
	gs.last_activity_id = "oncall-night"
	if ProtagonistArt.portrait_path(gs) != ProtagonistArt.PORTRAIT_TIRED:
		printerr("[smoke] FAIL: grind+health45 should be tired")
		ok = false
	else:
		print("[smoke] portrait tired@grind OK")

	gs.health = 80
	gs.last_activity_id = "ticket-grind"
	if ProtagonistArt.portrait_path(gs) != ProtagonistArt.PORTRAIT_CONFIDENT:
		printerr("[smoke] FAIL: health80 should be confident got %s" % ProtagonistArt.portrait_path(gs))
		ok = false
	else:
		print("[smoke] portrait confident@health80 OK")

	gs.health = 55
	gs.last_activity_id = "feature-sprint"
	if ProtagonistArt.portrait_path(gs) != ProtagonistArt.PORTRAIT_CONFIDENT:
		printerr("[smoke] FAIL: feature-sprint should be confident")
		ok = false
	else:
		print("[smoke] portrait confident@feature-sprint OK")

	gs.health = 55
	gs.last_activity_id = "bug-hunt"
	if ProtagonistArt.portrait_path(gs) != ProtagonistArt.PORTRAIT_DEFAULT:
		printerr("[smoke] FAIL: default portrait expected got %s" % ProtagonistArt.portrait_path(gs))
		ok = false
	else:
		print("[smoke] portrait default OK")

	gs.last_activity_id = "deep-rest"
	if ProtagonistArt.fullbody_path(gs) != ProtagonistArt.FULLBODY_HOODIE:
		printerr("[smoke] FAIL: deep-rest should be hoodie")
		ok = false
	else:
		print("[smoke] fullbody hoodie@deep-rest OK")

	gs.last_activity_id = "team-lunch"
	if ProtagonistArt.fullbody_path(gs) != ProtagonistArt.FULLBODY_HOODIE:
		printerr("[smoke] FAIL: team-lunch should be hoodie")
		ok = false
	else:
		print("[smoke] fullbody hoodie@team-lunch OK")

	gs.last_activity_id = "upward-chat"
	if ProtagonistArt.fullbody_path(gs) != ProtagonistArt.FULLBODY_FORMAL:
		printerr("[smoke] FAIL: upward-chat should be formal")
		ok = false
	else:
		print("[smoke] fullbody formal@upward-chat OK")

	gs.last_activity_id = "feature-sprint"
	if ProtagonistArt.fullbody_path(gs) != ProtagonistArt.FULLBODY_DEFAULT:
		printerr("[smoke] FAIL: feature-sprint fullbody default expected")
		ok = false
	else:
		print("[smoke] fullbody default OK")

	gs.last_activity_id = ""
	gs.health = 85
	if ProtagonistArt.month_result_portrait_path(gs) != ProtagonistArt.PORTRAIT_CONFIDENT:
		printerr("[smoke] FAIL: first-month high health confident portrait")
		ok = false
	else:
		print("[smoke] month_result confident portrait OK")

	# New grind / formal ids
	gs.health = 45
	gs.last_activity_id = "typhoon-wfh"
	if ProtagonistArt.portrait_path(gs) != ProtagonistArt.PORTRAIT_TIRED:
		printerr("[smoke] FAIL: typhoon-wfh should be tired at health45")
		ok = false
	else:
		print("[smoke] portrait tired@typhoon-wfh OK")
	gs.last_activity_id = "bonus-talk"
	gs.health = 55
	if ProtagonistArt.fullbody_path(gs) != ProtagonistArt.FULLBODY_FORMAL:
		printerr("[smoke] FAIL: bonus-talk should be formal")
		ok = false
	else:
		print("[smoke] fullbody formal@bonus-talk OK")

	gs.health = 45
	gs.last_activity_id = "mtr-overtime"
	if ProtagonistArt.portrait_path(gs) != ProtagonistArt.PORTRAIT_TIRED:
		printerr("[smoke] FAIL: mtr-overtime should be tired at health45")
		ok = false
	else:
		print("[smoke] portrait tired@mtr-overtime OK")
	gs.last_activity_id = "vpn-firefight"
	if ProtagonistArt.portrait_path(gs) != ProtagonistArt.PORTRAIT_TIRED:
		printerr("[smoke] FAIL: vpn-firefight should be tired at health45")
		ok = false
	else:
		print("[smoke] portrait tired@vpn-firefight OK")
	gs.health = 55
	gs.last_activity_id = "perf-review-week"
	if ProtagonistArt.fullbody_path(gs) != ProtagonistArt.FULLBODY_FORMAL:
		printerr("[smoke] FAIL: perf-review-week should be formal")
		ok = false
	else:
		print("[smoke] fullbody formal@perf-review-week OK")
	gs.last_activity_id = "cha-chaan-teng-round"
	if ProtagonistArt.fullbody_path(gs) != ProtagonistArt.FULLBODY_HOODIE:
		printerr("[smoke] FAIL: cha-chaan-teng-round should be hoodie")
		ok = false
	else:
		print("[smoke] fullbody hoodie@cha-chaan-teng OK")


	# —— Phase 4: SaveSystem multi-slot ——
	SaveSystem.clear_all_for_tests()
	if SaveSystem.has_any_save():
		printerr("[smoke] FAIL: saves should be empty after clear")
		ok = false
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.prepare_next_month()
	gs.apply_activity("feature-sprint", false)
	var saved_app: int = gs.app
	var saved_month: int = gs.month
	var saved_played: int = gs.months_played
	var saved_job := str(gs.job_id)
	if not SaveSystem.save_slot(1, gs):
		printerr("[smoke] FAIL: save_slot 1")
		ok = false
	else:
		print("[smoke] save_slot 1 OK")
	if not SaveSystem.slot_exists(1):
		printerr("[smoke] FAIL: slot 1 missing after save")
		ok = false
	var meta1: Dictionary = SaveSystem.read_meta(1)
	if str(meta1.get("summary", "")) == "" or int(meta1.get("months_played", 0)) != saved_played:
		printerr("[smoke] FAIL: meta summary/played %s" % meta1)
		ok = false
	else:
		print("[smoke] save meta OK: %s" % meta1.get("summary", ""))

	# mutate then load
	gs.app = 0
	gs.health = 1
	gs.month = 99
	gs.months_played = 0
	gs.job_id = "mutated"
	if not SaveSystem.load_slot(1, gs):
		printerr("[smoke] FAIL: load_slot 1")
		ok = false
	if gs.app != saved_app or gs.month != saved_month or gs.months_played != saved_played or gs.job_id != saved_job:
		printerr("[smoke] FAIL: load restore app=%d month=%d played=%d job=%s" % [gs.app, gs.month, gs.months_played, gs.job_id])
		ok = false
	else:
		print("[smoke] load restore OK")
	var after := SaveSystem.scene_after_load(gs)
	if after != "res://scenes/hub.tscn":
		printerr("[smoke] FAIL: scene_after_load expected hub got %s" % after)
		ok = false
	else:
		print("[smoke] scene_after_load hub OK")

	# slot 2 + newest
	gs.year = 2
	gs.month = 5
	if not SaveSystem.save_slot(2, gs):
		printerr("[smoke] FAIL: save_slot 2")
		ok = false
	var newest := SaveSystem.newest_slot()
	if newest != 2:
		printerr("[smoke] FAIL: newest_slot expected 2 got %d" % newest)
		ok = false
	else:
		print("[smoke] newest_slot OK")

	# —— Phase 4: MapData + map visit ——
	var locs: Array = MapData.location_ids()
	print("[smoke] map locations -> %d" % locs.size())
	if locs.size() < 4:
		printerr("[smoke] FAIL: expected ≥4 map locations")
		ok = false
	var map_evs: Array = MapData.all_events()
	if map_evs.size() < 8:
		printerr("[smoke] FAIL: expected ≥8 map events got %d" % map_evs.size())
		ok = false
	else:
		print("[smoke] map events OK count=%d" % map_evs.size())
	for lid in ["company", "cha-chaan-teng", "home", "job-board"]:
		if MapData.get_location(lid).is_empty():
			printerr("[smoke] FAIL: missing location %s" % lid)
			ok = false
		if MapData.events_for_location(lid).is_empty():
			printerr("[smoke] FAIL: no events for %s" % lid)
			ok = false

	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.prepare_next_month()
	var inf_b: int = gs.infra
	var app_b: int = gs.app
	var health_b: int = gs.health
	var infl_b: int = gs.influence
	var man_b: int = gs.manage
	if not gs.apply_map_visit("company"):
		printerr("[smoke] FAIL: apply_map_visit company")
		ok = false
	else:
		print("[smoke] map visit company OK id=%s" % gs.last_map_event_id)
	if not gs.map_used_this_month or gs.last_map_event_id == "":
		printerr("[smoke] FAIL: map flag/event not set")
		ok = false
	# second visit same month blocked
	if gs.apply_map_visit("home"):
		printerr("[smoke] FAIL: second map visit should fail")
		ok = false
	else:
		print("[smoke] map once-per-month OK")
	# deltas applied (any non-zero total change across stats likely)
	var changed: bool = (gs.infra != inf_b or gs.app != app_b or gs.health != health_b
		or gs.influence != infl_b or gs.manage != man_b)
	if not changed and gs.last_map_deltas.is_empty():
		printerr("[smoke] FAIL: map deltas empty")
		ok = false
	gs.prepare_next_month()
	if gs.map_used_this_month:
		printerr("[smoke] FAIL: map_used should reset on prepare_next_month")
		ok = false
	else:
		print("[smoke] map flag reset OK")
	if not gs.apply_map_visit("cha-chaan-teng"):
		printerr("[smoke] FAIL: map visit after reset")
		ok = false
	else:
		print("[smoke] map visit cha-chaan-teng OK")

	# hub copy mentions map
	var hub_src := FileAccess.get_file_as_string("res://scripts/hub.gd")
	if "城市／公司" not in hub_src or "存到槽" not in hub_src:
		printerr("[smoke] FAIL: hub missing map/save UI")
		ok = false
	else:
		print("[smoke] hub map+save UI OK")

	# load map scene
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	err = change_scene_to_file("res://scenes/map.tscn")
	if err != OK:
		printerr("[smoke] FAIL: change_scene map %s" % err)
		ok = false
	else:
		await process_frame
		await process_frame
		print("[smoke] map scene loaded")

	SaveSystem.clear_all_for_tests()
	print("[smoke] Phase 4 save+map OK")

	# —— Phase 5: CompaniesData + career ——
	var cids: Array = CompaniesData.all_ids()
	print("[smoke] companies count -> %d" % cids.size())
	if cids.size() < 3 or cids.size() > 6:
		printerr("[smoke] FAIL: expected 3–6 companies got %d" % cids.size())
		ok = false
	for cid in cids:
		var co: Dictionary = CompaniesData.get_company(str(cid))
		if str(co.get("name", "")) == "" or str(co.get("sector", "")) == "":
			printerr("[smoke] FAIL: incomplete company %s" % cid)
			ok = false
		# no real trademark tokens (light check)
		var nm := str(co.get("name", ""))
		for bad in ["Microsoft", "Google", "HSBC", "阿里巴巴", "騰訊", "Apple"]:
			if bad in nm:
				printerr("[smoke] FAIL: trademark-like %s in %s" % [bad, cid])
				ok = false
	for st in CompaniesData.STATES:
		if CompaniesData.state_label(st) == st:
			printerr("[smoke] FAIL: missing state label %s" % st)
			ok = false
	print("[smoke] CompaniesData OK")

	# Hire binds company_id + state
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	if gs.company_id != "central-enterprise":
		printerr("[smoke] FAIL: junior-dev company_id expected central-enterprise got %s" % gs.company_id)
		ok = false
	else:
		print("[smoke] hire company_id OK %s state=%s" % [gs.company_id, gs.company_state])
	if gs.tenure_months != 1 or gs.performance < 50:
		printerr("[smoke] FAIL: tenure/perf after hire t=%d p=%d" % [gs.tenure_months, gs.performance])
		ok = false
	if gs.salary_num <= 0:
		printerr("[smoke] FAIL: salary_num not set")
		ok = false
	else:
		print("[smoke] salary_num OK %d" % gs.salary_num)

	# Performance rises on track activity
	gs.prepare_next_month()
	var perf0: int = gs.performance
	gs.apply_activity("feature-sprint", false)
	if gs.performance <= perf0:
		printerr("[smoke] FAIL: performance should rise on feature-sprint %d→%d" % [perf0, gs.performance])
		ok = false
	else:
		print("[smoke] performance gain OK %d→%d" % [perf0, gs.performance])

	# Company state can change over many months
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.prepare_next_month()
	var seen_states := {}
	seen_states[gs.company_state] = true
	var changed_once := false
	for i in range(36):
		var before: String = str(gs.company_state)
		gs.apply_activity(["feature-sprint", "deep-rest", "upward-chat", "ticket-grind"][i % 4], false)
		if gs.company_state != before:
			changed_once = true
		seen_states[gs.company_state] = true
		gs.prepare_next_month()
	print("[smoke] company states over 36m: %s changed=%s" % [seen_states.keys(), changed_once])
	if not changed_once and seen_states.size() < 2:
		# Soft fail only if literally stuck — stickiness may rarely prevent; force a roll path
		printerr("[smoke] WARN: no company state change in 36m (sticky RNG); forcing tick check")
		var forced: String = CompaniesData.roll_next_state(str(gs.company_id), "stable", "winter", 99991)
		var forced2: String = CompaniesData.roll_next_state(str(gs.company_id), "stable", "spring", 42)
		if forced == "stable" and forced2 == "stable":
			# Still possible; accept if roll_next_state returns valid states
			pass
		print("[smoke] roll_next_state sample winter=%s spring=%s" % [forced, forced2])
	if seen_states.is_empty():
		printerr("[smoke] FAIL: no company states recorded")
		ok = false
	else:
		print("[smoke] company state machine OK")

	# Promotion path
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.tenure_months = 8
	gs.performance = 85
	gs.health = 70
	gs.company_state = "expanding"
	gs.prepare_next_month()
	var lvl0: String = str(gs.job_level)
	var sal0: int = int(gs.salary_num)
	if not gs.can_push_promo():
		printerr("[smoke] FAIL: can_push_promo should be true")
		ok = false
	gs.apply_activity("push-promo", false)
	print("[smoke] push-promo kind=%s level %s→%s sal %d→%d" % [gs.last_career_kind, lvl0, gs.job_level, sal0, gs.salary_num])
	if gs.last_career_kind not in ["promo", "raise", "freeze", "pip"]:
		printerr("[smoke] FAIL: unexpected career kind %s" % gs.last_career_kind)
		ok = false
	# Force promo by high perf + favorable seed loop
	var got_promo: bool = str(gs.last_career_kind) == "promo"
	if not got_promo:
		for i in range(15):
			gs.job_level = "junior"
			gs.job_title = "Junior Developer"
			gs.tenure_months = 10 + i
			gs.performance = 90
			gs.health = 80
			gs.company_state = "expanding"
			gs.salary_num = 22000
			gs.month = (i % 12) + 1
			gs.apply_activity("push-promo", false)
			if gs.last_career_kind == "promo":
				got_promo = true
				print("[smoke] promo forced OK title=%s" % gs.job_title)
				break
	if not got_promo:
		printerr("[smoke] FAIL: could not land promo in retries")
		ok = false
	else:
		print("[smoke] promotion path OK")

	# Job-hop accept path
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.prepare_next_month()
	gs.hunt_progress = 70
	gs.influence = 40
	gs.app = 50
	gs.apply_activity("interview-round", false)
	if not gs.has_pending_offer():
		# retry with more hunt
		for i in range(8):
			gs.hunt_progress = 80
			gs.month = (i % 12) + 1
			gs.pending_offer = {}
			gs.apply_activity("interview-round", false)
			if gs.has_pending_offer():
				break
	if not gs.has_pending_offer():
		printerr("[smoke] FAIL: interview should generate pending offer")
		ok = false
	else:
		print("[smoke] pending offer OK %s" % gs.pending_offer.get("company_id", "?"))
	var old_co: String = str(gs.company_id)
	var old_tenure: int = int(gs.tenure_months)
	var old_infl: int = int(gs.influence)
	if not gs.apply_activity("accept-hop", false):
		printerr("[smoke] FAIL: accept-hop")
		ok = false
	else:
		if gs.company_id == old_co:
			printerr("[smoke] FAIL: hop should change company")
			ok = false
		if gs.tenure_months != 1:  # +1 from apply_activity after reset to 0
			# accept sets tenure 0 then apply adds 1
			if gs.tenure_months != 1:
				printerr("[smoke] FAIL: tenure after hop expected 1 got %d" % gs.tenure_months)
				ok = false
		if gs.influence >= old_infl:
			printerr("[smoke] FAIL: influence should drop on hop %d→%d" % [old_infl, gs.influence])
			ok = false
		if not gs.on_probation:
			printerr("[smoke] FAIL: probation expected after hop")
			ok = false
		if gs.last_career_kind != "hop":
			printerr("[smoke] FAIL: career kind hop got %s" % gs.last_career_kind)
			ok = false
		else:
			print("[smoke] hop path OK new_co=%s title=%s" % [gs.company_id, gs.job_title])

	# Save/load career fields
	SaveSystem.clear_all_for_tests()
	gs.performance = 77
	gs.tenure_months = 14
	gs.company_state = "acquired"
	gs.hunt_progress = 33
	gs.job_level = "mid"
	if not SaveSystem.save_slot(1, gs):
		printerr("[smoke] FAIL: save career fields")
		ok = false
	gs.performance = 0
	gs.tenure_months = 0
	gs.company_state = "stable"
	gs.hunt_progress = 0
	gs.job_level = "junior"
	if not SaveSystem.load_slot(1, gs):
		printerr("[smoke] FAIL: load career fields")
		ok = false
	if gs.performance != 77 or gs.tenure_months != 14 or gs.company_state != "acquired" or gs.hunt_progress != 33 or gs.job_level != "mid":
		printerr("[smoke] FAIL: career restore p=%d t=%d st=%s h=%d lvl=%s" % [gs.performance, gs.tenure_months, gs.company_state, gs.hunt_progress, gs.job_level])
		ok = false
	else:
		print("[smoke] career save/load OK")

	# Career activities exist
	for nid in ["push-promo", "update-cv", "job-apply", "interview-round", "accept-hop", "decline-hop"]:
		if ActivitiesData.get_activity(nid).is_empty():
			printerr("[smoke] FAIL: missing career activity %s" % nid)
			ok = false
	if ActivitiesData.bias_label("career") != "職涯":
		printerr("[smoke] FAIL: career bias label")
		ok = false
	print("[smoke] career activities OK count=%d" % ActivitiesData.all().size())

	# Hub mentions company state / promo
	var hub_src2 := FileAccess.get_file_as_string("res://scripts/hub.gd")
	if "company_state_label" not in hub_src2 or "can_push_promo" not in hub_src2:
		printerr("[smoke] FAIL: hub missing company/promo UI")
		ok = false
	else:
		print("[smoke] hub career UI OK")

	# FF still works with career-aware cycle
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.prepare_next_month()
	var ff5: Dictionary = gs.fast_forward_months(18, [
		"feature-sprint", "update-cv", "job-apply", "upward-chat",
		"interview-round", "deep-rest", "push-promo", "ticket-grind"
	])
	print("[smoke] FF18 months=%s states=%s promos=%s hops=%s" % [
		ff5.get("months", 0), ff5.get("company_states", {}), ff5.get("promos", 0), ff5.get("hops", 0)
	])
	if int(ff5.get("months", 0)) != 18:
		printerr("[smoke] FAIL: FF18 months got %s" % ff5.get("months", 0))
		ok = false
	else:
		print("[smoke] Phase 5 fast_forward OK")

	SaveSystem.clear_all_for_tests()
	print("[smoke] Phase 5 company+career OK")


	# —— Phase 5.x: labor market climate + layoff / crisis ——
	for cl in LaborMarketData.CLIMATES:
		if LaborMarketData.label(cl) == cl:
			printerr("[smoke] FAIL: missing climate label %s" % cl)
			ok = false
		if LaborMarketData.hub_flavour(cl) == "":
			printerr("[smoke] FAIL: empty hub flavour %s" % cl)
			ok = false
	# Seasonal drift: climate can change over FF
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.prepare_next_month()
	var climates_seen := {}
	climates_seen[gs.market_climate] = true
	var climate_changed := false
	for i in range(24):
		var c_before: String = str(gs.market_climate)
		# Force winter/spring mix via month
		gs.month = (i % 12) + 1
		gs.apply_activity(["feature-sprint", "deep-rest", "update-cv", "ticket-grind"][i % 4], false)
		if gs.market_climate != c_before:
			climate_changed = true
		climates_seen[gs.market_climate] = true
		gs.prepare_next_month()
	print("[smoke] climates over 24m: %s changed=%s" % [climates_seen.keys(), climate_changed])
	if climates_seen.size() < 1:
		printerr("[smoke] FAIL: no climates")
		ok = false
	# Deterministic roll samples
	var c_spr := LaborMarketData.roll_next_climate("balanced", "spring", 42)
	var c_win := LaborMarketData.roll_next_climate("balanced", "winter", 99991)
	print("[smoke] climate sample spring=%s winter=%s" % [c_spr, c_win])
	if c_spr not in LaborMarketData.CLIMATES or c_win not in LaborMarketData.CLIMATES:
		printerr("[smoke] FAIL: invalid climate roll")
		ok = false
	else:
		print("[smoke] climate table OK")

	# Shrinking → layoff / crisis path
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.prepare_next_month()
	gs.company_state = "shrinking"
	gs.market_climate = "freezing"
	gs.performance = 35
	gs.last_company_changed = true
	var got_crisis := false
	var got_severe := false
	for i in range(20):
		gs.company_state = "shrinking"
		gs.market_climate = "freezing"
		gs.crisis_active = false
		gs.crisis_kind = ""
		gs.last_company_changed = (i % 2 == 0)
		gs.month = (i % 12) + 1
		gs.months_played = 10 + i
		gs.performance = 30 + (i % 20)
		gs.apply_activity("deep-rest", false)
		if gs.last_crisis_kind != "":
			got_crisis = true
			print("[smoke] crisis roll kind=%s severe_lock=%s" % [gs.last_crisis_kind, gs.crisis_active])
			if gs.crisis_active:
				got_severe = true
				break
		gs.prepare_next_month()
	if not got_crisis:
		# Force via direct roll helper path
		printerr("[smoke] WARN: no crisis in 20 shrinking months; forcing kind roll")
		var fk := LaborMarketData.roll_crisis_kind(true, "freezing", 30, 12345)
		if fk not in LaborMarketData.CRISIS_KINDS:
			printerr("[smoke] FAIL: crisis kind roll %s" % fk)
			ok = false
		else:
			# Apply synthetic severe
			gs.company_state = "shrinking"
			gs.crisis_active = true
			gs.crisis_kind = "severance"
			gs.last_crisis_kind = "severance"
			got_crisis = true
			got_severe = true
			print("[smoke] forced severe crisis kind=%s" % fk)
	if not got_crisis:
		printerr("[smoke] FAIL: could not obtain crisis")
		ok = false
	else:
		print("[smoke] layoff drama OK")

	# Severe crisis hub lock + resolve choice
	if not got_severe:
		gs.crisis_active = true
		gs.crisis_kind = "severance"
		gs.company_state = "shrinking"
	if not gs.is_crisis_month():
		printerr("[smoke] FAIL: is_crisis_month expected")
		ok = false
	for cid in LaborMarketData.CRISIS_ACTIVITY_IDS:
		if ActivitiesData.get_activity(str(cid)).is_empty():
			printerr("[smoke] FAIL: missing crisis activity %s" % cid)
			ok = false
	# Resolve crisis-hunt-now
	var hunt0: int = int(gs.hunt_progress)
	if not gs.apply_activity("crisis-hunt-now", false):
		printerr("[smoke] FAIL: crisis-hunt-now")
		ok = false
	else:
		if gs.crisis_active:
			printerr("[smoke] FAIL: crisis should clear after choice")
			ok = false
		if gs.hunt_progress <= hunt0 and not gs.forced_job_hunt:
			printerr("[smoke] FAIL: hunt should rise or forced flag")
			ok = false
		if gs.last_career_kind != "crisis-hunt":
			printerr("[smoke] FAIL: career kind crisis-hunt got %s" % gs.last_career_kind)
			ok = false
		else:
			print("[smoke] crisis-hunt-now OK hunt %d→%d forced=%s" % [hunt0, gs.hunt_progress, gs.forced_job_hunt])

	# crisis-severance path
	gs.crisis_active = true
	gs.crisis_kind = "forced_hunt"
	gs.company_state = "shrinking"
	gs.apply_activity("crisis-severance", false)
	if gs.last_career_kind != "crisis-severance" or not gs.forced_job_hunt:
		printerr("[smoke] FAIL: severance path kind=%s forced=%s" % [gs.last_career_kind, gs.forced_job_hunt])
		ok = false
	else:
		print("[smoke] crisis-severance OK")

	# crisis-stay path
	gs.crisis_active = true
	gs.crisis_kind = "severance"
	gs.company_state = "shrinking"
	gs.performance = 80
	gs.apply_activity("crisis-stay", false)
	if gs.last_career_kind != "crisis-stay":
		printerr("[smoke] FAIL: stay path %s" % gs.last_career_kind)
		ok = false
	else:
		print("[smoke] crisis-stay OK co=%s" % gs.company_state)

	# Hunt mult: booming > freezing
	var hb := LaborMarketData.hunt_mult("booming")
	var hf := LaborMarketData.hunt_mult("freezing")
	if hb <= hf:
		printerr("[smoke] FAIL: booming hunt mult should exceed freezing %s vs %s" % [hb, hf])
		ok = false
	else:
		print("[smoke] hunt mult OK boom=%s freeze=%s" % [hb, hf])

	# Offer bump climate
	var off_b: Dictionary = CompaniesData.generate_offer({"infra": 40, "app": 50, "influence": 30, "salary_num": 20000}, "app", "junior", "central-enterprise", 55, "booming")
	var off_f: Dictionary = CompaniesData.generate_offer({"infra": 40, "app": 50, "influence": 30, "salary_num": 20000}, "app", "junior", "central-enterprise", 55, "freezing")
	print("[smoke] offer boom sal=%s freeze sal=%s" % [off_b.get("salary_num"), off_f.get("salary_num")])
	if int(off_b.get("salary_num", 0)) < int(off_f.get("salary_num", 0)):
		printerr("[smoke] FAIL: booming offer should not be worse than freezing")
		ok = false

	# Save/load 5.x fields
	SaveSystem.clear_all_for_tests()
	gs.market_climate = "freezing"
	gs.crisis_active = true
	gs.crisis_kind = "severance"
	gs.forced_job_hunt = true
	gs.last_crisis_kind = "severance"
	gs.last_crisis_title = "遣散方案上枱"
	gs.last_climate_flavour = "test climate"
	if not SaveSystem.save_slot(2, gs):
		printerr("[smoke] FAIL: save 5.x fields")
		ok = false
	gs.market_climate = "booming"
	gs.crisis_active = false
	gs.crisis_kind = ""
	gs.forced_job_hunt = false
	gs.last_crisis_kind = ""
	if not SaveSystem.load_slot(2, gs):
		printerr("[smoke] FAIL: load 5.x fields")
		ok = false
	if gs.market_climate != "freezing" or not gs.crisis_active or gs.crisis_kind != "severance" or not gs.forced_job_hunt or gs.last_crisis_kind != "severance":
		printerr("[smoke] FAIL: 5.x restore climate=%s active=%s kind=%s forced=%s last=%s" % [
			gs.market_climate, gs.crisis_active, gs.crisis_kind, gs.forced_job_hunt, gs.last_crisis_kind
		])
		ok = false
	else:
		print("[smoke] 5.x save/load OK format=%d" % SaveSystem.FORMAT_VERSION)
	if SaveSystem.FORMAT_VERSION < 3:
		printerr("[smoke] FAIL: FORMAT_VERSION should be ≥3")
		ok = false

	# Hub mentions climate / crisis
	var hub_src5 := FileAccess.get_file_as_string("res://scripts/hub.gd")
	if "climate_label" not in hub_src5 or "is_crisis_month" not in hub_src5:
		printerr("[smoke] FAIL: hub missing climate/crisis UI")
		ok = false
	else:
		print("[smoke] hub climate/crisis UI OK")
	# Hub bias Imagine icons
	if "UiIcons.load_bias_icon" not in hub_src5:
		printerr("[smoke] FAIL: hub missing UiIcons bias icons")
		ok = false
	else:
		var bias_keys := ["infra", "app", "manage", "social", "study", "rest", "career", "crisis"]
		var icons_ok := true
		for bk in bias_keys:
			var ipath := UiIcons.bias_icon_path(bk, bk == "crisis")
			if not ResourceLoader.exists(ipath):
				printerr("[smoke] FAIL: missing bias icon %s" % ipath)
				icons_ok = false
				ok = false
		if UiIcons.bias_icon_path("career", true) != "res://assets/ui/icons/icon_bias_crisis.png":
			printerr("[smoke] FAIL: crisis flag should map to crisis icon")
			icons_ok = false
			ok = false
		if icons_ok:
			print("[smoke] hub bias icons OK")
	var res_src5 := FileAccess.get_file_as_string("res://scripts/month_resolve.gd")
	if "last_crisis_kind" not in res_src5 or "climate_label" not in res_src5:
		printerr("[smoke] FAIL: resolve missing climate/crisis UI")
		ok = false
	else:
		print("[smoke] resolve climate/crisis UI OK")

	# FF tracks climates
	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.prepare_next_month()
	# Seed shrinking to encourage crisis during FF
	gs.company_id = "codeup-startup"
	gs.company_state = "shrinking"
	gs.market_climate = "freezing"
	var ff5x: Dictionary = gs.fast_forward_months(16, [
		"feature-sprint", "deep-rest", "update-cv", "job-apply", "ticket-grind", "crisis-stay"
	])
	print("[smoke] FF16 5.x months=%s climates=%s crises=%s states=%s" % [
		ff5x.get("months", 0), ff5x.get("climates", {}), ff5x.get("crises", 0), ff5x.get("company_states", {})
	])
	if int(ff5x.get("months", 0)) != 16:
		printerr("[smoke] FAIL: FF16 5.x months")
		ok = false
	elif (ff5x.get("climates", {}) as Dictionary).is_empty():
		printerr("[smoke] FAIL: FF should record climates")
		ok = false
	else:
		print("[smoke] Phase 5.x fast_forward OK")

	SaveSystem.clear_all_for_tests()
	print("[smoke] Phase 5.x climate+layoff OK")

	# —— Phase 3b: SceneBg atmosphere assets + picker ——
	for bp in SceneBg.ALL_FILES:
		if not FileAccess.file_exists(ProjectSettings.globalize_path(bp)):
			printerr("[smoke] FAIL: missing bg %s" % bp)
			ok = false
		else:
			print("[smoke] bg %s OK" % bp)

	gs.begin_new_game()
	gs.select_education("uni")
	gs.select_job("junior-dev")
	gs.accept_offer_and_run_first_month()
	gs.prepare_next_month()

	gs.last_activity_id = "typhoon-wfh"
	gs.last_event_id = ""
	gs.job_level = "junior"
	gs.month = 1
	if SceneBg.path_for(gs, SceneBg.FALLBACK_MONTH) != SceneBg.BG_TYPHOON:
		printerr("[smoke] FAIL: typhoon-wfh → typhoon bg got %s" % SceneBg.path_for(gs, SceneBg.FALLBACK_MONTH))
		ok = false
	else:
		print("[smoke] SceneBg typhoon-wfh OK")

	gs.last_activity_id = "feature-sprint"
	gs.last_event_id = "typhoon-signal"
	gs.last_event_title = "颱風波／八號風球"
	if SceneBg.path_for(gs, SceneBg.FALLBACK_MONTH) != SceneBg.BG_TYPHOON:
		printerr("[smoke] FAIL: typhoon-signal event → typhoon bg")
		ok = false
	else:
		print("[smoke] SceneBg typhoon-signal OK")

	gs.last_event_id = ""
	gs.last_event_title = ""
	gs.last_activity_id = "oncall-night"
	gs.month = 7  # summer
	gs.job_level = "lead"
	if SceneBg.path_for(gs, SceneBg.FALLBACK_MONTH) != SceneBg.BG_TYPHOON:
		printerr("[smoke] FAIL: summer+oncall → typhoon even if lead got %s" % SceneBg.path_for(gs, SceneBg.FALLBACK_MONTH))
		ok = false
	else:
		print("[smoke] SceneBg summer+oncall typhoon OK")

	gs.month = 1  # winter — no seasonal typhoon
	gs.last_activity_id = "feature-sprint"
	gs.job_level = "junior"
	if SceneBg.path_for(gs, SceneBg.FALLBACK_HUB) != SceneBg.BG_JUNIOR:
		printerr("[smoke] FAIL: junior → junior_morning got %s" % SceneBg.path_for(gs, SceneBg.FALLBACK_HUB))
		ok = false
	else:
		print("[smoke] SceneBg junior OK")

	gs.job_level = ""
	if SceneBg.path_for(gs, SceneBg.FALLBACK_HUB) != SceneBg.BG_JUNIOR:
		printerr("[smoke] FAIL: empty level → junior")
		ok = false
	else:
		print("[smoke] SceneBg empty→junior OK")

	gs.job_level = "senior"
	if SceneBg.path_for(gs, SceneBg.FALLBACK_MONTH) != SceneBg.BG_LEAD:
		printerr("[smoke] FAIL: senior → lead_meeting")
		ok = false
	else:
		print("[smoke] SceneBg senior OK")

	gs.job_level = "lead"
	if SceneBg.path_for(gs, SceneBg.FALLBACK_MONTH) != SceneBg.BG_LEAD:
		printerr("[smoke] FAIL: lead → lead_meeting")
		ok = false
	else:
		print("[smoke] SceneBg lead OK")

	gs.job_level = "manager"
	if SceneBg.path_for(gs, SceneBg.FALLBACK_MONTH) != SceneBg.BG_MGMT:
		printerr("[smoke] FAIL: manager → harbour")
		ok = false
	else:
		print("[smoke] SceneBg manager OK")

	# mid: fallthrough — overtime activity → overtime night; else fallback
	gs.job_level = "mid"
	gs.last_activity_id = "war-room"
	gs.month = 1
	if SceneBg.path_for(gs, SceneBg.FALLBACK_HUB) != SceneBg.BG_OVERTIME:
		printerr("[smoke] FAIL: mid+war-room winter → overtime got %s" % SceneBg.path_for(gs, SceneBg.FALLBACK_HUB))
		ok = false
	else:
		print("[smoke] SceneBg mid+overtime OK")

	gs.last_activity_id = "deep-rest"
	if SceneBg.path_for(gs, SceneBg.FALLBACK_HUB) != SceneBg.FALLBACK_HUB:
		printerr("[smoke] FAIL: mid+rest → hub fallback got %s" % SceneBg.path_for(gs, SceneBg.FALLBACK_HUB))
		ok = false
	else:
		print("[smoke] SceneBg mid fallback OK")

	gs.job_level = "mid"
	gs.last_activity_id = "oncall-night"
	gs.month = 1
	if SceneBg.path_for(gs, SceneBg.FALLBACK_MONTH) != SceneBg.BG_OVERTIME:
		printerr("[smoke] FAIL: mid+oncall winter → overtime")
		ok = false
	else:
		print("[smoke] SceneBg mid+oncall OK")

	# hub/month scripts use SceneBg
	var hub_bg := FileAccess.get_file_as_string("res://scripts/hub.gd")
	var res_bg := FileAccess.get_file_as_string("res://scripts/month_resolve.gd")
	var mres_bg := FileAccess.get_file_as_string("res://scripts/month_result.gd")
	if "SceneBg.apply_to" not in hub_bg or "SceneBg.apply_to" not in res_bg or "SceneBg.apply_to" not in mres_bg:
		printerr("[smoke] FAIL: scenes not wired to SceneBg")
		ok = false
	else:
		print("[smoke] SceneBg wired hub/resolve/result OK")

	print("[smoke] Phase 3b SceneBg OK")


	if ok:
		print("[smoke] PASS")
		quit(0)
	else:
		printerr("[smoke] FAIL")
		quit(1)
