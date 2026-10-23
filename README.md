# 《香港IT人》（hkitguy）

香港 IT 職涯模擬人生。對外名稱《香港IT人》；專案資料夾 **hkitguy**。


## 線上玩（GitHub Pages）

玩法頁：[https://mhraymondwong.github.io/game-hkitguys/](https://mhraymondwong.github.io/game-hkitguys/)

倉庫：[https://github.com/mhraymondwong/game-hkitguys](https://github.com/mhraymondwong/game-hkitguys)

`gh-pages` 分支放 `build/web` 內容；`main` 放 Godot 源碼與匯出產物。

## 主線（Godot）

- **引擎**：Godot **4.7.2.stable**（`config/features` **4.7**＋Forward Plus；本機 bin：`/home/box/bin/godot`）
- **解析度／語系**：1280×720｜繁體中文（`zh_Hant`）；必嵌 Noto Sans CJK TC
- **結構**：`scenes/`、`scripts/`、`assets/`、`docs/`、`shots/`、**GameState** autoload
- **美術**：最終圖像經 Grok Imagine；開局 BG＋主角已置入；Hub／月結沿用 job／month 底；其他關鍵畫面仍待 ≥8 版面 MC
- **願景**：由後生入職做到退休——每月一決策、Infra／Application 分線（見 DESIGN.md）

規格：[DESIGN.md](./DESIGN.md)（**v2.0.1**）。管線：[docs/PIPELINE.md](./docs/PIPELINE.md)。

## 點樣跑（Phase 1–5.x）

```bash
# 編輯器／試玩（F5 等同）
godot --path .

# 匯入檢查
godot --headless --path . --quit-after 1

# 煙霧測試
godot --headless --path . --script res://scripts/smoke_test.gd

# 標題截圖（需顯示；headless 可能黑圖）
xvfb-run -a godot --path . --script res://scripts/capture_title.gd

# Phase 2 hub／月結截圖
xvfb-run -a godot --path . --script res://scripts/capture_phase2.gd

# Phase 4 存檔／地圖；Phase 5 公司／升遷跳槽；Phase 5.x 市況／裁員
xvfb-run -a godot --path . --script res://scripts/capture_phase4.gd
xvfb-run -a godot --path . --script res://scripts/capture_phase5.gd
xvfb-run -a godot --path . --script res://scripts/capture_phase5x.gd
```

流程：標題（新局／讀檔）→ 綜合／大學畢業 → 入職職位 → 確認 Offer → 第一個月 → **繼續打工**（Hub 揀月活動／存檔／城市地圖 → 月結 → 下個月…）／返回標題。


## Web 匯出（Phase C）

HTML5／nothreads 匯出到 `build/web/`（preset 名 **Web**；`variant/thread_support=false`）。

```bash
cd .
./scripts/export_web.sh
# 或：GODOT_BIN=/home/box/bin/godot ./scripts/export_web.sh
```

產出：`build/web/index.html`／`index.js`／`index.wasm`／`index.pck`（另複製 `public/_headers`）。大檔部署優先 GitHub Pages；本腳本只做匯出、不自動部署。

規格詳見 [DESIGN.md](./DESIGN.md)（Phase C）。

## HTML 簡單版（僅參考）

`simple/index.html` 是早期拋棄式 wireframe，**不是**主交付線。

## 與《時光裡的她》

同引擎世代與管線習慣；**零劇情／美術共用**（僅允許複製開源字型 Noto Sans CJK TC）。本專案由 **Game Designer 2** 負責。
