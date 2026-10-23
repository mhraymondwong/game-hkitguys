# 《香港IT人》（hkitguy）— 高標準製作管線

> 規格真相仍以根目錄 [`DESIGN.md`](../DESIGN.md) 為準；本檔記錄**工程／美術／Phase 門檻**，對齊 peer《時光裡的她》的高標準做法。  
> **只學骨架與管線，禁止抄襲對方劇情、角色、美術資產。**  
> 專案路徑：`/workspace/agents/Game Designer 2/hkitguy/`  
> 風格錨點：**新海誠風原創空氛**｜開局：**學歷 → 入職職位**  
> 版本對齊：DESIGN **v0.5.1**（2026-10-21）

---

## 1. Godot 引擎與專案慣例

| 項目 | 決定 |
|------|------|
| 版本 | **Godot 4.7.2.stable**（跟最新穩定版，不追 nightly） |
| `project.godot` | `config/features` 含 **`4.7`**；renderer 預設 **Forward Plus**；Web 可用 **`gl_compatibility`** |
| 主場景 | `run/main_scene` 必須明確 |
| 狀態 | **GameState** Autoload（年月、學歷、職位、路線、屬性、公司、存檔 API） |
| Viewport | **1280×720**；`window/stretch/mode=canvas_items` |
| 語系 | `locale/fallback=zh_Hant`；繁中 UI／文案（對話可偏粵） |
| 字型 | **必嵌** `theme/custom_font`（Noto Sans CJK TC）；Web **不可**靠系統字 |
| 目錄 | `scenes/`、`scripts/`、`assets/`、`docs/`、`shots/`（截圖驗收）、`build/web`（HTML5 匯出） |
| 規格 | **`DESIGN.md`＝規格真相**；本檔＝管線；變更先寫 DESIGN／PIPELINE 再實作 |
| 匯出 | HTML5 preset → `build/web`；腳本化（如 `scripts/export_web.sh`） |
| 部署 | 大檔優先 **GitHub Pages**；勿把 Cloudflare Workers 25MiB 上限當主部署路徑 |

### 本專案開局骨架（Phase 1 最小可玩）

標題 → **綜合畢業／大學畢業** → **入職職位**（Infra／App）→ Offer 確認 → 第一個月結算 → 可再玩。

---

## 2. Grok Imagine 美術管線

**全部最終遊戲圖像必須經 Grok Imagine**；StyleBox／純色佔位僅過渡，不可當最終美術。  
**禁止**版權畫面、截圖、偽聯名、peer 專案資產。

### 2.1 美術方向鎖定（Phase 0 強制）

1. 出任何正式圖前，先用 **≥8 個版面／構圖 multiple-choice** 問 Raymond 鎖方向（標題、開局、工卡 HUD、月結、城市／公司地圖等關鍵畫面）。  
2. 選項卡須附**建議選擇**。  
3. 鎖定後寫入 `DESIGN.md`／本檔，再批量產圖。

### 2.2 Prompt 模板（新海誠風空氛・原創）

```
anime style, soft Makoto Shinkai–inspired atmosphere (original, not a copy),
warm Hong Kong city light and sky, [subject], [career stage / season / wardrobe],
full body / portrait, clean edges, transparent-friendly,
no text, no watermark, no logos
```

- 同一角色／主角視角加**固定描述錨點句**，保跨圖一致性。  
- 標註為「受新海誠美學愛好啟發的原創空氛」；永不聲稱官方聯名。

### 2.3 解析度與格式

| 用途 | 建議 |
|------|------|
| 立繪／過場肖像 | 邊長約 **1024–1536** |
| UI／地圖／背景 | 對齊 **16:9**（1280×720） |
| Web 體積 | 背景可 **jpg**；角色／UI 框 **png**（透明） |
| 特別活動 | 可另出 still + 短片（GenerateVideo），非必須於早期 Phase |

### 2.4 命名與後處理

- 語意路徑示例：  
  - `assets/portraits/career_{stage}.png`  
  - `assets/bg/{scene_id}.jpg`  
  - `assets/ui/{panel_id}.png`  
  - `assets/endings/{ending_id}.jpg`  
- Godot Import 跟專案預設。  
- **必做後處理**：去背、修邊緣透明窿（flood-fill／手動修）；勿只用 Pillow 程序圖當主美術。  
- Web 注意 pck／wasm 體積；大圖壓縮後再進 `build/web`。

### 2.5 一致性

- 固定 prompt 錨點；職涯立繪階段（入行→站穩→帶人→管理→高階→收成）分檔換圖。  
- 季節／加班夜／颱風天等氛圍可分檔，不改月格邏輯。

---

## 3. Phase 切法（企劃 → 可玩 → 打磨 → 部署）

| Phase | 目標 | 本專案重點 |
|-------|------|------------|
| **0** | 多選鎖定 → 寫進 DESIGN | 引擎 4.7.2.stable、Imagine、新海誠風；**≥8 版面 MC 鎖美術**；開局學歷→職位已鎖 |
| **1** | 核心迴圈可玩 | Godot 骨架＋標題→學歷→職位→第一個月；佔位 UI OK |
| **2–3** | 事件＋成長美術 | 月活動／季節權重；職涯階段立繪／衣櫃；關鍵 Imagine 定稿開始替換 |
| **4** | 地圖＋存檔 | 城市／公司地圖事件；多槽存檔 |
| **5** | 內容深度 | 公司狀態機、跳槽／升遷、心情／門檻、勞動市場 |
| **6–8** | 打磨感 | 年末回顧、結局片尾、標題畫面定稿、教學 |
| 之後 | 玩法 feat → 部署 | 過場／NPC／相簿等；HTML5 → `build/web` → GitHub Pages |

> 舊文「骨架→迴圈→UI→Imagine」已併入上表；細節以本檔為準，摘要仍寫在 DESIGN §15。

### 門檻（每 Phase 完成條件）

- **smoke script PASS**（可自動化最小流程）  
- **關鍵畫面截圖**入 `shots/`  
- 規格變更已寫進 **DESIGN.md**（必要時同步本檔）  
- **禁止偷工**：未嵌字型、灰系統預設窗當最終 UI、佔位當最終美術、年齡／內容尺度失控

### UI／文案門檻

- 禁長期停留在 Godot 預設灰窗；正式殼參考市面成品（工卡＋月曆／週報感）  
- 按鈕大、繁中清楚；教學＋多槽存檔（Phase 4+）  
- 港式職場寫實＋輕量溫暖；成人懷舊、無露骨

### Playtest／技術

- 整局或加速煙霧跑一輪；記漏洞  
- 部署後強制硬刷新驗 Pages  
- 永遠對齊 **4.7.2.stable**（或 Raymond 另鎖之更新穩定版）；大檔部署路徑先想清楚

---

## 4. 「要求好高」Checklist（交付前自檢）

**美術**

- [ ] 最終資產皆 Imagine；立繪無透明窿  
- [ ] 風格錨點一致（新海誠風原創空氛）  
- [ ] 結局／標題／回顧各有鎖定版面（經 ≥8 選 MC）

**UX**

- [ ] 非灰預設窗；工卡／月曆資訊層級清楚  
- [ ] 繁中＋可讀；開局學歷→職位路徑無死角

**文案**

- [ ] zh-Hant；港式語氣；無露骨、無真實商標人身攻擊

**Playtest**

- [ ] smoke PASS；關鍵 `shots/`；部署後硬刷新驗證

**技術**

- [ ] Godot **4.7.2.stable**；字型嵌入；DESIGN／PIPELINE 已更新  
- [x] HTML5 → `build/web`（Phase C DONE；`./scripts/export_web.sh`）；部署／Pages 另開

---

## 5. 與 peer 的界線

| 可對齊 | 不可做 |
|--------|--------|
| Godot 版號／features、1280×720、GameState、目錄、Imagine 門檻、Phase／smoke／shots | 抄劇情、角色、立繪、結局文、對方 `assets/` |
| 匯出與部署策略 | 共用或改動《時光裡的她》專案 |

本專案負責人：**Game Designer 2**。Peer 建議可參考；資產與劇情完全獨立。

---

## 6. 澄清 Raymond 時的形式

凡需拍板：用 **multiple choice**，並標明**建議選擇**（與用戶指示一致）。美術方向鎖定時選項數 **≥8**。
