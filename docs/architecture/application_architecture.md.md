# Application Architecture

本プロジェクトの技術選定およびディレクトリ構造、フロントエンドとバックエンドの連携方針について記述します。

## 1. Core Stack
- **JS Framework:** 

| 要素 | 技術 / ツール | 備考 |
| --- | --- | --- |
| **フレームワーク** | **Ruby on Rails (Version 7.2.2)** | 安定版のバージョンを選択 |
| **CSS フレームワーク** | **Tailwind CSS** | `tailwindcss-rails` を使用。ユーティリティファーストでの実装。 |
| **JS フレームワーク** | **Hotwire (Turbo + Stimulus)** | コントローラベース（`Flash`, `Navbar`等）で最小限のJSを記述。 |
| **JS 管理** | **Importmap** | Node.js/npm に依存しないRails標準のJS管理。 |
| **アイコン** | （未定義） | 現状は独自実装またはSVGなどを想定。要設計 |

## 2. Frontend Architecture
UI/UXを実現するためのコンポーネント管理と振る舞いの定義です。

### 2.1 UI Components (View)
外部ライブラリに依存せず、Rails標準の **Partial（部分テンプレート）** を活用した独自実装を行っています。
- **レイアウト** 
  - `app/views/layouts/application.html.erb` (2ペイン固定レイアウト)
- **共通パーツ**
  - `_navbar.html.erb`: レスポンシブ対応のナビゲーション（`NavbarController` で制御）
  - `_flash.html.erb`: トースト型通知。表示後、`FlashController` で自動フェードアウト。

* **ドメインパーツ:**
* `_task.html.erb`: タスク一覧のアイテム。
* `_form.html.erb`: タスク入力用の共通フォーム。

### 2.2 JavaScript Behavior (Stimulus)
`app/javascript/controllers/` 配下で、DOM要素に紐づく振る舞いを管理します。
- `flash_controller.js`: 通知の自動フェードアウト制御
- `navbar_controller.js`: モバイルメニューのトグル制御

## 3. Asset Pipeline & Build（静的ファイルの管理とビルドの仕組み）
- **JS Management:** 
  - Importmap (No-node environment)
    - JSをビルド（バンドル）せずに、そのままブラウザに配信するための交通整理役。
- **CSS Build:** Tailwind CSS CLI (Output: `assets/builds/tailwind.css`)
  -  Tailwind のビルド済み CSS（`tailwind.css`）を出力し、Rails から読み込み。
  -  application.tailwind.css を元に、実際に使っているスタイルだけを集めた tailwind.css を assets/builds/ に書き出す作業。

## 4. Progressive Web Apps (PWA)
ネイティブアプリのような体験を提供するための設定が含まれています。
- **Manifest:** `public/manifest.json.erb`: アプリ名やアイコンの定義。
- **Service Worker:** `app/javascript/service-worker.js`: オフライン対応やキャッシュ制御の基盤。

## 5. タスク関連ドメイン項目の扱い（補足）

- `priority_group`  
  - DB上では `p1`, `p2`, `p3` の文字列として保存する。  
  - 画面表示やi18nでは `P1`, `P2`, `P3` として扱う想定。
- `story_point`  
  - `0` を未設定（未見積もり）として扱い、実際の見積もり値としては `1`, `3`, `5` を使用する。  
  - 集計やグラフ表示時には `0` を除外することで「見積もり済みタスク」の実績を算出しやすくする。

