# 《香港IT人》— 玩法規格（v2.0.1）

> 專案 id／資料夾：**hkitguy**  
> 對外名稱：**《香港IT人》**  
> 原創養成／模擬人生。結構靈感參考同系列養成（《時光裡的她》：年／月活動排程／屬性／多結局），**劇情、角色、美術完全獨立，禁止抄襲對方資產**。  
> 與既有 agent「Game Designer」的《時光裡的她》是不同專案，互不接手。  
> **主線引擎：Godot 4.7.2.stable**（`config/features` **4.7**＋Forward Plus；對齊 peer；跟最新穩定版，不追 nightly）  
> **管線規格**：[docs/PIPELINE.md](./docs/PIPELINE.md)（Godot／Grok Imagine／Phase 門檻；本檔仍為玩法真相）  
> 介面語言：**繁體中文**（`zh_Hant`；對話可偏粵）｜港式職場寫實＋輕量溫暖敘事  
> **全部遊戲圖像：Grok Imagine**（與 peer 同品質門檻：佔位不可當最終美術；風格＝**新海誠風空氛**、原創 prompt；**永不**使用版權畫面／截圖／聯名）  
>
> **已鎖定（Raymond，2026-10-21）**：
> - 類型：**大項目／細緻模擬人生**（有心理準備：系統厚、內容多）
> - 時間（完整版）：**由後生入職做到退休**（約 22→65 歲，約 **40+ 年**）
> - 排程（完整版）：**每月 1 格**，全程固定 → 約 40×12 ＝ **~480** 決策格
> - 結局：**多結局**（IT Director 只是其中一條）
> - 入職：**可選 Infra 或 Application** 路線（之後可轉）
> - 職涯動作：**轉職搵工** 與 **公司內升職加薪** 並存
> - 公司動態：服務中的公司可能 **擴充、被收購、執笠（倒閉）**
> - 遊戲名稱：**香港IT人**；專案路徑：**hkitguy**
> - **引擎主線：Godot 4.7.2.stable**（features 4.7；詳見 PIPELINE.md）
> - **Phase 0 標題／空氛方向 LOCKED（Raymond，2026-10-21）**：**morning-office-sky**（清晨辦公室窗邊・藍空軟雲）
> - **標題底圖**：Grok Imagine 已置入 `assets/title_bg.jpg`（`UiStyle.add_texture_background`）
> - **開局背景 batch（2026-10-21）**：`assets/edu_bg.jpg`／`job_bg.jpg`／`month_bg.jpg` 已置入 education／job＋offer／month_result（同一 morning-office-sky 系列）
> - **主角立繪 LOCKED（Raymond，2026-10-22）**：**male-short-shirt-badge**（短髮男・休閒襯衫・入職工卡）
> - **主角資產**：`assets/protagonist/portrait_badge.jpg`（半身／工卡）＋`assets/protagonist/fullbody.jpg`（全身）；已置入 title／offer／month_result
> - **Phase D 主角變體 LOCKED（Raymond，2026-10-22，all-four）**：`portrait_tired.jpg`／`portrait_confident.jpg`／`fullbody_hoodie.jpg`／`fullbody_formal.jpg`；切換：`scripts/protagonist_art.gd`（健康／上次活動 → 表情；rest／social／向上管理 → 服裝）
> - **Phase C Web 匯出 DONE（2026-10-22）**：preset **Web** → `build/web/index.html`；`scripts/export_web.sh`；nothreads；`public/_headers`；重建：`./scripts/export_web.sh`
> - **UI 殼 LOCKED（Raymond，2026-10-22）**：**E glass RPG**（否決 hybrid A＋E／A／B）；示意 `shots/ui_mocks/E_glass_rpg.jpg`
> - **HUD／header 規則**：chrome **唔好印遊戲名「香港IT人」**（怪）；標題畫面主標題可保留；hub／學歷／職位／Offer／月結 header 只顯示年月／職位／薪／狀態
> - **開局打磨 A DONE（Raymond，2026-10-22）**：title→education→job→offer→month_result；glass 步驟 pill；粵語微文案；CTA「繼續 · …」；smoke 加 opening polish 斷言；截圖 01–04／03b
> - **Phase 3a 系統 DONE（Raymond，2026-10-22）**：季節權重＋活動／事件表＋`fast_forward_months`；美術 Imagine 留 3b
> - **內容擴充 DONE（Raymond A＋B，2026-10-22）**：活動 20→28、事件 12→20；季節／立繪規則已接；smoke PASS
> - **Phase 3b 氛圍 LOCKED all-five（Raymond，2026-10-22）**：五款職涯／mood 背景已接 `SceneBg`；hub／月結動態換底
> - **Phase 5.x 勞動市場／裁員 DONE（2026-10-22）**：`LaborMarketData` booming／balanced／freezing；shrinking→layoff／危機月；活動＋3；Save FORMAT **3**
> - **Web 重匯 after 5.x DONE（2026-10-22 14:14 HKT）**：`build/web`（wasm≈38MiB、pck≈42MiB、合計≈80MiB）；含勞動市場／裁員；未 Pages
> - **美術主線：全部資產經 Grok Imagine**（新海誠風原創空氛；禁止版權圖）；**UI 殼已鎖 E**；地圖等其餘關鍵畫面仍須 ≥8 版面 MC 再批量產圖
> - **`simple/index.html` 僅為拋棄式 wireframe／手感參考**；**不再當主交付線**
> - 工程對齊 peer 結構習慣：**1280×720**、`zh_Hant`、`scenes/`／`scripts/`／`assets/`、**GameState autoload**——只學骨架，**不抄**對方劇情／美術
> - 已否決：15 年短養成、三段時間壓縮、每年僅 4 格、暫名「螢幕前的他」、HTML 當最終產品

---

## A. HTML 簡單版 — 僅參考（非主線）

路徑：`simple/index.html`。

用途：早期驗證「學歷 → 職位 → 第一個月結果」手感的**拋棄式 wireframe**。  
**狀態（v0.5.1）**：保留供對照文案／職位池意圖；**主線為 Godot 4.7.2.stable**；勿再擴充 HTML 當正式版本。

### 曾涵蓋流程（參考）

1. 標題：《香港IT人》
2. 選學歷：綜合畢業／大學畢業
3. 選入職職位（Infra／App 各若干）
4. 確認 Offer → 第一個月結果摘要 → 再玩

### 學歷差異（設計意圖；Godot 開局沿用）

| | 綜合畢業 | 大學畢業 |
|--|----------|----------|
| 敘事 | 實務／支援入門多 | 開發／分析入門略多 |
| 起薪帶 | 略低 | 略高 |
| 職位池 | 偏 Helpdesk／NOC／App Support；部分 Junior 開發門檻較高 | 多 Junior Dev／BA junior；Helpdesk 仍可選 |
| 開局屬性 | Infra／App 基礎略偏實務 | 對應路線基礎略高、影響力略高 |

### 入職職位樣本（設計意圖）

**綜合畢業可選（示例）**：Helpdesk、Desktop Support、NOC、Sysadmin Junior、Application Support、Junior Developer（有限）。  
**大學畢業可選（示例）**：Helpdesk、Sysadmin Junior、Cloud／Infra Trainee、Junior Developer、BA Junior、Application Support。

### 美術備註

- HTML 內僅 CSS 空氛示意；**正式立繪／背景／UI 框一律 Grok Imagine 後置入 Godot**
- 標註「受新海誠美學啟發的原創空氛」；**禁止**版權圖或偽聯名

---

## B. 完整版願景（Godot 主線）

以下 §1–§16 為完整模擬人生願景；實作按 §15 Phase，由 Godot 骨架起跑。

## 1. 定位

| 項目 | 決定 |
|------|------|
| 對象 | 大人／IT 從業者；願意玩長局的細緻模擬 |
| 玩家視角 | **第一人稱**：你就是主角 |
| 主角 | 香港 IT 人；第一份工起做到退休 |
| 開局 | **學歷**（綜合／大學）→ **入職職位**（Infra 或 App 向） |
| 世界 | 香港職場生態＋**可演變的雇主公司** |
| 尺度 | 細緻職場模擬；加班／政治／裁員／收購可出現，不過度陰暗；無露骨 |
| 結局 | 多維人生／職涯多結局 |
| 介面 | **E glass RPG**（frosted glass＋屬性環＋玻璃活動格＋橙 CTA）；標題可顯示遊戲名；HUD 禁遊戲名；地圖殼＋**公司／職涯 HUD**（Phase 5） |
| 體量 | **大項目**：公司模擬、勞動市場、雙路線技能樹皆要細 |
| 引擎 | Godot **4.7.2.stable**｜**1280×720**｜`zh_Hant`｜詳見 [PIPELINE.md](./docs/PIPELINE.md) |
| 美術 | **全部** Grok Imagine；新海誠風原創空氛；Phase 0 **≥8 版面 MC** 鎖方向 |

**一句話賣點**：由後生入行做到退休——每月一決，在會擴張、被收購或執笠的公司裡，揀 Infra 定 App、留低定跳槽，寫出你的香港 IT 人生。

## 2. 時間結構

- **總長**：約 **40+ 年**（建議 22→65；可提早退休／被迫離場／延退）
- **排程（已定）**：**每月選 1 項主活動**，全年 12 格，生涯均等
- **體量**：~480 主決策 ＋ 地圖事件、公司事件、市場事件 → 需分 Phase 實作與大量內容管線
- **月／季氛圍**（事件權重，非改格數）：春財年／夏升級／秋審計資安／冬 Bonus 跳槽季
- **職涯立繪階段**：入行 → 站穩 → 帶人 → 管理 → 高階 → 收成（Imagine 換圖，不改月格）
- **結束條件**：到退休年／財務自由／Burnout／裁後轉行不回流／特殊旗標

## 3. 核心迴圈（每月）

1. **公司／城市地圖** → 八卦、機會、風險  
2. **本月活動**（1 格）  
3. **結算**：個人屬性＋公司狀態＋市場訊號  
4. **觸發事件**（升遷談薪、面試、收購傳聞、執笠預兆等）  
5. **下月**；年末考核／回顧；結束條件 → 結局  

## 4. 數值

### 個人（HUD）

| 屬性 | 含義 |
|------|------|
| **Infra 力** | 網路、伺服器、雲基建、維運、監控 |
| **App 力** | 開發／支援應用、需求、發布、整合 |
| **管理力** | 帶人、專案、預算、供應商 |
| **影響力** | 向上管理、跨部門、談判 |
| **健康** | 過低鎖高強度月活動／觸發 burnout |

> 開局主修路線對應屬性成長較快；跨線可學但較慢。可保留綜合「技術力」為兩者衍生顯示。

### 旗標／資源

- **證照庫**、**人情帳**、**履歷聲望**
- **存款／薪級／Bonus 期望**
- **在職狀態**：現職公司 id、職級、部門、年資、績效分
- **求職狀態**：是否在搵工、面試進度、Offer 清單
- **學歷**：綜合畢業／大學畢業（影響開局職位池與起薪）

## 5. 開局路線：學歷 → 職位 → Infra / Application

1. 選 **綜合畢業** 或 **大學畢業**  
2. 選 **入職職位**（職位帶路線標籤）  
3. 路線可由職位推導；之後可透過學習／調職／跳槽轉線  

| 路線 | 典型入門職 | 早期活動偏重 | 中後期可通向 |
|------|------------|--------------|--------------|
| **Infrastructure** | Helpdesk／Desktop／NOC／Sysadmin junior | 值班、Ticket、Patch、Backup、Network | Infra Manager → Head of Infra → IT Director／雲架構大牛 |
| **Application** | App Support／Junior Dev／BA junior | 應用支援、UAT、小改、發版協助 | Team Lead → Eng Manager → Head of App／產品技術 |

- **轉線**：學習月、內部調職、或跳槽（有冷卻與能力門檻）
- **雙棲**：中後期可成「懂 App 的 Infra」或相反，影響獨特結局

## 6. 職涯雙通道：留任 vs 轉職

### 公司內（留低）

- 績效、專案功勞、人情 → **升職**／**加薪**／轉組
- 年終考核；PIP／凍薪風險；內部空缺競聘

### 外部（轉職搵工）

- 月活動：更新履歷、投遞、面試、談薪、放假深造
- Offer 受履歷聲望、路線匹配、市場景氣、現職公司穩定性影響
- 跳槽代價：年資重置、人情部分流失、試用期風險；換取薪級／職級／路線轉換

## 7. 公司模擬（細緻核心系統）

| 公司狀態 | 玩家感受 |
|----------|----------|
| **擴充** | 招人、新專案、升遷坑位多、加班也可能多 |
| **穩定** | 日常運維為主 |
| **被收購** | 整合、重複崗位、新文化、留任獎勵或裁員骰 |
| **執笠／大幅收縮** | 欠薪風險、遣散、被迫求職；可觸發劇情月 |

第一版可用 **3–6 間虛構雇主模板**（金融 IT、零售、MSP、政府相關外判、初創、大型企業）＋程序化狀態機，**避免真實商標**。

## 8. 活動類別（每月選一）

本業（依路線）、專案、學習／證照、人脈、向上管理、求職、內部爭取、休息／生活、危機應對（公司事件鎖定期）。

## 9. 地圖地點（港味）

Helpdesk／機房／開發樓層／Boardroom／茶餐廳／電腦中心／港鐵夜歸／家／數碼港·科學園·中環／求職平台 UI。  
地圖事件與**現職公司狀態**聯動。

## 10. 結局（多維）

職位帶 × 財富 × 健康 × 家庭 × 居住地 × **最後雇主命運**。  
第一版目標 **12–16** 個命名結局，之後可擴。

## 11. 敘事調性

- 書面繁中為主，口語可偏粵（搞掂、出 ticket、執笠、跳槽）
- 真實感：audit、ransomware drill、收購 due diligence、裁員、欠薪傳聞
- 禁止真實公司商標與人身攻擊

## 12. 技術與美術（v0.5.1 鎖定）

> 完整管線、Phase 門檻、Imagine prompt／驗收見 **[docs/PIPELINE.md](./docs/PIPELINE.md)**。

| 項目 | 決定 |
|------|------|
| 引擎 | **Godot 4.7.2.stable**（features `4.7`；Forward Plus；Web 可用 `gl_compatibility`） |
| 解析度 | **1280×720** 橫向；`window/stretch/mode=canvas_items` |
| 語言／字型 | `locale/fallback=zh_Hant`；**必嵌** Noto Sans CJK TC（`theme/custom_font`） |
| 目錄 | `scenes/`、`scripts/`、`assets/`、`docs/`、`shots/`、`build/web` |
| 狀態 | **GameState** autoload（年月、屬性、學歷、職位、公司 id、存檔） |
| 美術 | **全部圖像經 Grok Imagine**；新海誠風**原創**空氛；佔位不可當最終；**禁灰系統預設窗當最終 UI** |
| 美術鎖定 | Phase 0：正式產圖前 **≥8 版面 MC**（附建議選項）問 Raymond |
| Imagine | 立繪 1024–1536；UI／背景 16:9；固定角色錨點；語意路徑；去背後處理；jpg 背景＋png 角色 |
| 匯出／部署 | HTML5 → `build/web`；大檔優先 GitHub Pages |
| 資料 | 活動、公司模板、事件表盡量 JSON／資源檔 |
| HTML | `simple/index.html`＝**參考用 wireframe only** |
| 隔離 | 與《時光裡的她》**零資產／劇情共用**；只對齊工程／管線習慣 |
| 禁止 | 任何受版權保護的新海誠作品圖像、商標、截圖 |

## 13. 不做（仍適用）

- 語音、線上、內購  
- 真實商標  
- 不改動《時光裡的她》專案  
- 版權美術／抄圖  
- 以 HTML 簡單版當正式產品線

## 14. 與《時光裡的她》

| | 時光裡的她 | 本專案 |
|--|--|--|
| 引擎 | Godot 4.7.2.stable／features 4.7 | **同 4.7.2.stable**（跟穩定版） |
| 解析度／語系 | 1280×720、zh_Hant | 同 |
| 骨架習慣 | scenes／scripts／assets、GameState | 同習慣，**不抄內容** |
| 美術管線 | 全部 Grok Imagine | 同門檻；風格改為**新海誠風空氛原創** |
| 類型 | 養成＋地圖＋多結局 | 同，但加**公司／勞動市場模擬** |
| 時間 | 12 年×每月 1 | **~40 年×每月 1（~480 格）** |
| 主題 | 養育女兒 | 香港 IT 人生 |
| 額外系統 | — | 學歷開局、Infra/App 分線、跳槽、公司擴充／收購／執笠 |

## 15. 實作順序（對齊 PIPELINE：0 鎖定 → 1 可玩迴圈 → … → 部署）

完整門檻見 [docs/PIPELINE.md](./docs/PIPELINE.md) §3–§4。每 Phase：**smoke PASS**＋`shots/` 截圖＋規格已寫進本檔。

### Phase 0 — 規格／美術方向鎖定

- 引擎 **4.7.2.stable**、Imagine 管線、HTML 降級已鎖定（Phase 1 開局切片已 DONE）
- **標題／空氛方向 LOCKED**：**morning-office-sky**（清晨辦公室窗邊・藍空軟雲）；`assets/title_bg.jpg` 已置入標題畫面
- **開局背景 batch 已置入**：`edu_bg.jpg`（學歷）／`job_bg.jpg`（職位＋Offer）／`month_bg.jpg`（第一個月）；`UiStyle.add_texture_background` 統一 full-bleed＋wash
- **其餘關鍵畫面**（工卡 HUD／地圖等）：仍須以 **≥8 版面 multiple-choice**（附建議選項）問 Raymond 後才批量產正式圖
- 內容表骨架（活動／公司模板／結局 id）持續補

### Phase 1 — 可玩核心迴圈（Godot 骨架）✅ DONE（2026-10-21）

**狀態**：開局垂直切片已可玩；標題＋開局三張 Imagine 背景已置入（morning-office-sky 系列）；**主角立繪已鎖並置入**；**UI 殼已鎖 E glass RPG**（見下方 UI 殼條）。

1. ✅ Godot 工程：`project.godot`（name《香港IT人》、features **4.7**、main `scenes/title.tscn`、**1280×720**、`zh_Hant`、嵌 Noto、`gl_compatibility`）
2. ✅ 目錄：`scenes/`、`scripts/`、`assets/fonts`、`docs/`、`shots/`
3. ✅ **GameState** autoload：學歷、職位、路線、屬性、薪級、公司、`begin_new_game`／第一個月結算
4. ✅ 場景：`title` → `education` → `job` → `offer` → `month_result` → 再玩
5. ✅ smoke_test.gd；截圖 `shots/01_title.png`／`02_education.png`／`03_job.png`／`03b_offer.png`／`04_month.png`
5b. ✅ 主角 Imagine：`assets/protagonist/portrait_badge.jpg`＋`fullbody.jpg`（male-short-shirt-badge）
6. ✅ README：**4.7.2.stable**／`/home/box/bin/godot`

### Phase 2 — 每月活動迴圈 ✅ DONE（2026-10-22）

**狀態**：開局後可連續多月揀活動→結算；Phase 4 存檔＋地圖；**Phase 5＋5.x** 公司／升遷／跳槽／勞動市場／裁員危機；**Phase 3b 氛圍 all-five 已接**；未做結局／轉組／心情／額外立繪。

1. ✅ `scripts/activities_data.gd`（12 項；bias＋deltas＋zh-Hant flavour；`activities_for_track` 權重排序）
2. ✅ GameState：`year`／`month`／`months_played`、`apply_activity`、`prepare_next_month`、stats clamp 0–100、`last_activity_*`／`last_deltas`
3. ✅ 場景：`hub.tscn`（HUD＋揀 1 活動）→ `month_resolve.tscn`（flavour＋deltas）
4. ✅ `month_result` 主 CTA「繼續打工」→ `prepare_next_month`＋hub；副「返回標題」
5. ✅ smoke 模擬 3 個月活動＋hub／resolve 載入；截圖 `shots/05_hub.png`／`06_month_resolve.png`（並刷新 04）

### Phase D — 主角表情／服裝變體 ✅ DONE（2026-10-22）

**LOCKED（Raymond all-four）**：在既有 `portrait_badge`／`fullbody` 之上加四款變體。

| 檔 | 用途 |
|----|------|
| `portrait_tired.jpg` | 疲憊加班半身＋工卡 |
| `portrait_confident.jpg` | 自信微笑半身＋工卡 |
| `fullbody_hoodie.jpg` | 休閒 hoodie 全身（休息／週末） |
| `fullbody_formal.jpg` | 正裝全身（向上管理／面試感） |

**切換一覽**（`scripts/protagonist_art.gd`）：portrait＝健康≤35 或 grind 活動且健康≤50 → tired；健康≥70 或 upward-chat／team-lunch／feature-sprint → confident；否則 default。fullbody＝deep-rest／rest／team-lunch → hoodie；upward-chat／面試提示 → formal；否則 default。hub 用 portrait；month_resolve 用 fullbody；title／offer 維持 default。


### Phase C — Web／HTML5 匯出 ✅ DONE（2026-10-22）

1. ✅ `export_presets.cfg` preset **Web** → `build/web/index.html`；`variant/thread_support=false`；VRAM compression off；`canvas_resize_policy=2`
2. ✅ `scripts/export_web.sh`（`--import` → `--export-release "Web"`；驗 index.html／js／wasm／pck；複製 `_headers`）
3. ✅ `public/_headers`（.wasm／.pck／.js MIME；no-cache）
4. ✅ 本機匯出成功；重建：`./scripts/export_web.sh`（`GODOT_BIN` 可覆寫）
5. 部署（GitHub Pages）**未做**——僅匯出；大檔優先 Pages，非 Cloudflare 25MiB


### UI 殼 — E glass RPG ✅ LOCKED（2026-10-22）

**LOCKED（Raymond）**：正式殼＝**E glass RPG**（否決 hybrid A＋E）。參考 `shots/ui_mocks/E_glass_rpg.jpg`。

| 元素 | 實作 |
|------|------|
| 面板 | frosted glass（半透明藍灰）＋ cyan／gold 柔光邊（`UiStyle.glass_style`） |
| Hub | header＝年月／職位／公司／薪（**無遊戲名**）；左＝立繪＋五色屬性 orb 環；右＝玻璃活動格（選取 cyan glow）；底＝軟橙 CTA |
| 開局／月結 | 同 glass 語言；`make_card_panel`／`make_flavour_panel`／彩色 `make_stat_chip` |
| 標題 | 主標題可顯示《香港IT人》；glass menu card＋橙「開始入行」 |
| 工卡 | badge header＝「員工證」（唔再印 HONG KONG IT／遊戲名） |
| 背景 | 維持 morning-office-sky Imagine；wash 略加深等 glass 浮起 |

### 開局打磨 A ✅ DONE（2026-10-22）

在 E glass 殼上收緊開局手感（title→學歷→職位→Offer→滿月）：

| 項 | 內容 |
|----|------|
| 步驟標籤 | `UiStyle.make_step_tag` → gold-rim **glass pill**（①／③ 學歷／②／③ 入職／③／③ 聘用／入職滿月） |
| 標題 | pill「港式職場模擬」＋主標題《香港IT人》＋「開始入行」；tip 無 meta「開局」字眼 |
| CTA | 「繼續 · 揀職位」「繼續 · 睇 Offer」「接受聘用，上班去」「繼續打工」 |
| Offer | 「確認你嘅 Offer」；工卡「員工證／準員工」；內卡 gold rim；路徑金字 |
| 月結 | tip「蜜月期捱完…」；stat chips 不變 |
| HUD | 非標題畫面 **禁**「香港IT人」（smoke 斷言） |

smoke PASS；重截 `shots/01`–`04`／`03b`。

### Phase 3a — 季節／活動／事件系統 ✅ DONE（2026-10-22）

**狀態（Raymond 揀 phase3 → 建議切片 3a）**：系統向；**未做**職涯階段立繪／氛圍 Imagine／關鍵 UI 框產圖（留 Phase 3b＋MC）。

| 項 | 內容 |
|----|------|
| 季節 | `ActivitiesData.season_of_month`：春 3–5／夏 6–8／秋 9–11／冬 12–2；`activities_for_track_season` 當季 boost 置頂（★／★季） |
| 季節感覺 | 夏偏 oncall／war-room／颱風 WFH；冬偏 deep-rest／證照／bonus；春開坑／向上；秋 audit／patch |
| Hub chrome | `calendar_label` 含「春／夏／秋／冬」；header 第二行 `season_label_full`；步驟 pill「本月計劃 · 夏」等；**仍禁遊戲名** |
| 活動擴充 | ＋8：`typhoon-wfh`／`audit-prep`／`bonus-talk`／`meetup-night`／`ransomware-drill`／`side-project`／`mentor-junior`／`vendor-poc`（當時總 20；其後見下節擴至 28） |
| 事件表 | `scripts/events_data.gd`（當時 12；季節加權；`roll_event` ~70%；其後擴至 20）；`GameState.apply_activity` 後套用；月結顯示「本月插曲」 |
| 加速鉤子 | `GameState.fast_forward_months(n, cycle)`（僅 smoke／debug）；smoke 模擬 12 月跨四季＋事件 |
| 截圖 | `shots/05_hub.png`（夏／★）；`06_month_resolve.png`（活動＋插曲） |

### Phase 3 內容擴充 ✅ DONE（2026-10-22）

**狀態（Raymond：A＋B → 內容 only；美術 3b 另開）**：活動／事件加料；**未做** Imagine／職涯立繪。

| 項 | 內容 |
|----|------|
| 活動 | 20→**28**（＋8）：`mtr-overtime`／`cha-chaan-teng-round`／`morning-daily`／`cloud-migration`／`hackathon-blitz`／`perf-review-week`／`vpn-firefight`／`knowledge-base` |
| 事件 | 12→**20**（＋8）：`layoff-rumor`／`acquisition-rumor`／`vpn-outage`／`door-access-down`／`mtr-signal-fault`／`hackathon-poster`／`tea-room-news`／`cloud-bill-spike` |
| 季節 | `SEASON_BOOST_IDS` 接入新 id（夏 OT／VPN；秋評核／上雲；冬茶餐廳／知識庫；春 daily／hackathon） |
| 立繪規則 | `ProtagonistArt`：grind＋mtr／vpn／cloud；confident＋hackathon／daily／茶餐廳；formal＋perf-review；hoodie＋茶餐廳／hackathon |
| 截圖 | 重截 `shots/05_hub.png`／`06_month_resolve.png` |
| 未做（已於 3b 補氛圍） | 額外職涯全身立繪／UI 框 MC |

### Phase 3b — 氛圍背景 ✅ LOCKED all-five（2026-10-22）

**狀態（Raymond 鎖 all-five）**：五款職涯／mood 氛圍圖已置入並接線；**未做**額外職涯全身立繪／關鍵 UI 框 MC。

| 項目 | 內容 |
|------|------|
| 資產 | `assets/bg/`：`stage_junior_morning.jpg`／`stage_overtime_night.jpg`／`stage_lead_meeting.jpg`／`stage_mgmt_harbour.jpg`／`mood_typhoon_wfh.jpg` |
| Helper | `scripts/scene_bg.gd`（`class_name SceneBg`） |
| 接線 | `hub.gd`／`month_resolve.gd`／`month_result.gd` → `SceneBg.apply_to`（title／edu／job／offer 仍用固定底） |
| 切換優先序 | ① mood 颱風／黑雨（`typhoon-wfh`／`typhoon-signal`／夏秋＋oncall／war-room／vpn）→ ② `job_level`（junior／空→junior_morning；**mid→不選 stage，落入③④**；senior／lead→lead_meeting；manager+→harbour）→ ③ overtime 活動（oncall／war-room／mtr／vpn／patch）→ ④ 場景 fallback（hub=`job_bg`；月結=`month_bg`） |
| 截圖 | 重截 `shots/04_month`／`05_hub`／`06_month_resolve`（＋`10_hub_company` 經理海傍） |
| 未做 | 額外職涯全身立繪變體；地圖等其餘畫面專屬氛圍 |

### Phase 4 — 地圖＋存檔（DONE · 2026-10-22）

| 項目 | 內容 |
|------|------|
| 存檔 | `SaveSystem`（`scripts/save_system.gd`）**3 槽** JSON → `user://saves/slot_N.json`；`GameState.to_save_dict`／`apply_save_dict` |
| 標題 | 「開始入行」＋「繼續最近進度」＋讀取槽 1–3；讀檔後 `scene_after_load`（`months_played>0`→hub） |
| Hub | 「存到槽 N」＋「城市／公司」入口；HUD 仍禁遊戲名 |
| 地圖 | `scenes/map.tscn`；地點：公司樓層／茶餐廳／屋企／求職平台；`MapData` 12 短事件；**每月 1 次**（`map_used_this_month`，`prepare_next_month` 重置） |
| UI | 沿用 **E glass RPG**；地圖用 `month_bg`；**未**新 Imagine |
| 截圖 | `shots/07_title_load.png`／`08_hub_map.png`／`09_map.png`（＋`09b_map_result`） |
| 氛圍 | Phase 3b all-five 已接（見上） |

### Phase 5 — 公司模擬＋升遷／跳槽（可玩切片 DONE · 2026-10-22）

| 項目 | 內容 |
|------|------|
| 雇主模板 | `CompaniesData` **6** 間虛構：半島 MSP／港灣零售／海旁金融／公民系統外判／碼上初創／中環企業；sector＋base_stability；**禁真實商標** |
| 公司狀態機 | `expanding`／`stable`／`acquired`／`shrinking`；月結漂移（穩定度＋季節＋黏性）；hub／月結顯示 |
| 內部（留低） | `tenure_months`／`performance`／`job_level`；`push-promo`→升職／加薪／凍薪／PIP；門檻年資＋績效 |
| 外部（跳槽） | 求職活動＋地圖求職平台→Offer→接受／拒絕；年資重置、人情↓、試用期 |
| 存檔 | 新欄位；FORMAT_VERSION **2** |
| 截圖 | `shots/10_hub_company.png`／`11_resolve_career.png`／`11b_resolve_hop.png` |
| 5.x | **DONE** 見下節；仍未做：轉組、心情細化、地圖×公司深聯動 |



### Phase 5.x — 勞動市場景氣＋裁員／執笠戲劇月（DONE · 2026-10-22）

| 項目 | 內容 |
|------|------|
| 市況 | `LaborMarketData`：`booming`／`balanced`／`freezing`；季節漂移（春偏旺、夏黏平穩、秋偏凍、冬跳槽季＋雙向波動） |
| 影響 | hunt_progress 倍率；外部 Offer 薪級 bump；公司狀態機 shrinking／expanding 權重；hub chrome 短文案（**禁遊戲名**） |
| 裁員月 | `company_state==shrinking` 時擲 `pip`／`freeze`／`rumor`／`severance`／`forced_hunt`；嚴重者鎖下月計劃 |
| 危機選項 | `crisis-stay`／`crisis-severance`／`crisis-hunt-now`（取代普通活動表） |
| 存檔 | 新欄位；FORMAT_VERSION **3** |
| 截圖 | `shots/12_hub_market.png`／`12b_hub_crisis.png`／`13_resolve_layoff.png` |
| 未做 | 轉組、心情系統、地圖×公司深聯動、Web 重匯、結局 |

### Phase 6–8 — 打磨（標題／回顧／結局）

- 年末回顧、結局片尾、標題定稿、教學
- 全程煙霧（可加速 480 月）

### 之後 — 玩法 feat → 部署

- 過場／NPC／相簿等；**Phase C Web 匯出已 DONE**（`build/web`）；部署／Pages 另開

> HTML `simple/` **不再佔 Phase 序位**；僅作文案／流程參考。

## 16. 待 Raymond 拍板

1. **名稱／路徑**：已定《香港IT人》／**hkitguy**  
2. **引擎／美術主線**：已定 Godot **4.7.2.stable** ＋ Grok Imagine（本 v0.5.1；見 PIPELINE.md）  
2b. **Phase 0 標題空氛**：已鎖 **morning-office-sky**；開局 edu／job／month 背景 batch 已置入；**UI 殼已鎖 E glass RPG**；地圖等其餘畫面仍待 ≥8 選 MC  
2c. **主角立繪**：已鎖 **male-short-shirt-badge**；`portrait_badge`／`fullbody` 已置入；**Phase D all-four** 變體已鎖並接線  
3. **粵語濃度**  
4. **開局是否可選性別／本地身份**  
5. **第一版先做幾間虛構公司模板**（建議 3）  
6. **Infra/App 之外第一版要不要第三線**（如 Security）— 建議先兩線  
7. 開局職位池起薪數字／門檻是否再調  
8. Godot 已鎖 **4.7.2.stable**（若環境僅有更新穩定版，寫入 README 並回報）

---

## Phase 1–2 Godot 範圍（摘要）

**DONE（v2.0.1）**：Godot **4.7.2.stable** 開局＋月迴圈＋主角變體＋Web 匯出＋**E glass RPG**＋開局打磨＋季節／事件（37 活動／20 事件）＋**Phase 4** 存檔／地圖＋**Phase 5** 公司／升遷／跳槽＋**Phase 5.x** 勞動市場／裁員危機月＋**Phase 3b** 五款氛圍底（`SceneBg`）。標題空氛 **morning-office-sky**；主角錨點 **male-short-shirt-badge**。HTML simple 僅參考。**下一步**：額外職涯立繪／UI 框 MC；Phase 6 結局；Pages 部署另開。

---

## 修訂紀錄

| 版 | 日期 | 摘要 |
|----|------|------|
| v2.0.1 | 2026-10-22 | Web 重匯 after Phase 5.x：`build/web` wasm≈38MiB／pck≈42MiB／合計≈80MiB；含勞動市場／裁員；未 Pages |
| v2.0 | 2026-10-22 | Phase 5.x DONE：勞動市場 booming／balanced／freezing；shrinking→裁員／危機月（3 選項）；Save v3；smoke＋shots 12–13 |
| v1.9 | 2026-10-22 | Phase 3b 氛圍 LOCKED all-five：`assets/bg/` 五圖＋`SceneBg`；hub／月結動態 BG；smoke 斷言；重截 04–06／10 |
| v1.8 | 2026-10-22 | Phase 5 可玩切片：6 虛構雇主＋狀態機；績效／年資／職級；升職加薪＋跳槽 Offer；活動 28→34；smoke＋shots 10–11；3b 美術仍另開 |
| v1.7 | 2026-10-22 | Phase 4 DONE：3 槽 JSON 存檔（標題讀檔／Hub 存檔）；地圖殼 4 地點＋12 事件（每月 1 次）；smoke＋shots 07–09；3b 美術仍另開 |
| v1.6 | 2026-10-22 | 內容擴充：活動 20→28；事件 12→20；季節 boost／ProtagonistArt 接新 id；smoke≥24／≥16＋新 id；重截 05–06；3b 美術仍另開 |
| v1.5 | 2026-10-22 | Phase 3a 系統 DONE：季節權重（港式四季）；活動 12→20；`events_data` 12 項；hub／月結季節＋插曲；`fast_forward_months`；smoke 12 月 PASS；重截 05–06；3b 美術另開 |
| v1.4 | 2026-10-22 | 開局打磨 A：glass 步驟 pill；title／edu／job／offer／month_result 微文案＋層次；CTA「繼續 ·」；smoke opening polish 斷言；重截 01–04／03b |
| v1.3 | 2026-10-22 | UI 殼 LOCKED **E glass RPG**（否決 hybrid A＋E）；glass／屬性 orb 環／橙 CTA；HUD／header 禁「香港IT人」；開局文案收緊；smoke PASS；重截 01–06 |
| v1.2 | 2026-10-22 | Phase C Web 匯出 DONE：export_presets Web＋export_web.sh＋public/_headers；nothreads；build/web 已產出；smoke PASS |
| v1.1 | 2026-10-22 | Phase D 主角變體 LOCKED all-four；`ProtagonistArt` 表情／服裝切換；hub／month_resolve 接線；smoke 6 檔＋picker 斷言；shots 05–06 變體 |
| v1.0 | 2026-10-22 | Phase 2 月迴圈 DONE：ActivitiesData 12 項；GameState year／month／apply_activity；hub＋month_resolve；month_result→繼續打工；smoke 3 月活動；shots 05–06 |
| v0.9.1 | 2026-10-22 | Phase 1 開局 UI／文案打磨：去掉玩家可見 Phase／佔位註；步驟標籤；premium 工卡 Offer；月結 flavour 框＋stat chips；smoke 加 copy 斷言；重截 01–04／03b |
| v0.9 | 2026-10-22 | 主角立繪 LOCKED male-short-shirt-badge；`assets/protagonist/` 置入 title／offer／month_result；工卡／立繪框 helper；截圖含 03b_offer |
| v0.8 | 2026-10-21 | 開局 Imagine 背景 batch 置入 edu／job／month；`UiStyle.add_texture_background`；截圖 02–04；title 改用 helper |
| v0.7 | 2026-10-21 | Phase 0 標題空氛 LOCKED morning-office-sky；Imagine `assets/title_bg.jpg` 置入標題；截圖更新；其餘關鍵畫面 MC 仍 pending |
| v0.6 | 2026-10-21 | Phase 1 垂直切片 DONE：Godot 工程＋開局五場景＋GameState／JobsData＋smoke；佔位 UI；Phase 0 美術鎖仍 pending |
| v0.5.1 | 2026-10-21 | 鎖 4.7.2.stable；新增 docs/PIPELINE.md；Phase 0 強制 ≥8 版面 MC；Phase 表對齊 peer 高標準管線 |
| v0.5 | 2026-10-21 | 主線改 Godot＋Imagine；HTML 降為參考 |
