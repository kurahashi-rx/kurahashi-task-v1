## プロジェクト概要

自分専用の**タスク管理 & 日次レポートアプリ**。
タスクのスプリント管理と日次の振り返り（実績ポイント・勤務時間など）を記録する個人用Webアプリ。

---

## 技術スタック

| 要素 | 技術 |
|------|------|
| フレームワーク | Ruby on Rails 7.2.2 |
| DB | PostgreSQL（Dockerコンテナ） |
| CSS | Tailwind CSS（`tailwindcss-rails`） |
| JS | Hotwire（Turbo + Stimulus）、Importmap |
| サーバー | Puma（Railsデフォルト） |
| インフラ | AWS EC2（t4g.nano/micro）+ Docker Compose |
| 外部公開 | Cloudflare Tunnel（`cloudflared`コンテナ） |

---

## 主要コマンド

```bash
# 開発サーバー起動（CSS自動ビルド含む）
bin/dev

# Railsコンソール
rails console

# マイグレーション
rails db:migrate

# テスト（未設定の場合はコメントアウト）
# bundle exec rspec

# Lintチェック
bundle exec rubocop

# Dockerコンテナ起動（本番相当）
docker compose up -d

# Dockerコンテナ停止
docker compose down
```

---

## ディレクトリ構成（主要箇所）

```
app/
├── models/
│   ├── task.rb          # タスク管理モデル
│   └── daily_report.rb  # 日次レポートモデル
├── views/
│   ├── layouts/
│   │   └── application.html.erb  # 2ペイン固定レイアウト
│   └── tasks/
│       ├── _task.html.erb        # タスク一覧アイテム
│       └── _form.html.erb        # タスク入力フォーム
├── javascript/
│   └── controllers/
│       ├── flash_controller.js   # 通知フェードアウト制御
│       └── navbar_controller.js  # モバイルメニュートグル
└── assets/
    └── builds/
        └── tailwind.css          # Tailwindビルド済みCSS
```

---

## DB・データモデル

### Taskモデル

| カラム | 型 | 備考 |
|--------|----|------|
| status | string (enum) | `backlog / ready / sprint / done`。prefix必須 |
| category | string | 3文字の分類コード |
| title | string | タスク名称 |
| value | text | 提供できる価値 |
| definition_of_done | text | 完了定義 |
| procedures | text | 手順（Markdown形式） |
| priority_group | string (enum) | `p1 / p2 / p3`。画面表示は `P1/P2/P3` |
| story_point | integer | `0`=未設定、実績値は `1 / 3 / 5` |
| sort_order | integer | 並べ替え用 |
| completed_on | date | 完了日 |

### DailyReportモデル

| カラム | 型 | 備考 |
|--------|----|------|
| report_on | date | 日付 |
| work_hours | float | 勤務時間(h) |
| meeting_hours | float | 会議時間(h) |
| target_point | integer | 目標Pt |
| actual_point | integer | 完了実績Pt |
| reflection | text | 振り返り（Markdown形式） |
| comment | text | フィードバック内容（Markdown形式） |

> **注意**: `集中時間` や `キャパシティPt` などの計算項目はDBに保存しない。
> モデルのメソッドとして実装すること（`work_hours` と `meeting_hours` から算出）。

---

## コーディング規約

### Rails全般

- enumには必ず `_prefix: true` を設定する
- カラム命名: 日付は `_on`、日時は `_at`（Rails標準）
- `id`、`created_at`、`updated_at` はRails自動生成のため定義不要

### enumの例

```ruby
# 正しい実装
enum status: { backlog: "backlog", ready: "ready", sprint: "sprint", done: "done" }, _prefix: true
enum priority_group: { p1: "p1", p2: "p2", p3: "p3" }, _prefix: true
```

### priority_group の表示変換

- DB保存値: `p1 / p2 / p3`
- 画面表示値: `P1 / P2 / P3`（i18nまたはヘルパーで変換）

### story_point の扱い

- `0` = 未設定（未見積もり）
- 集計・グラフ表示時は `0` を除外する

### フロントエンド

- JSはStimulusコントローラーで最小限に記述
- CSSはTailwindのユーティリティクラスを使用（カスタムCSSは極力書かない）
- 外部UIライブラリは使用しない（Railsのpartialで独自実装）

---

## インフラ構成

```
[自分] → HTTPS → [Cloudflare Edge]
                        ↕ Secure Tunnel (Outbound only)
              [EC2 (t4g.nano/micro) / Docker Compose]
                  ├── cloudflared コンテナ（Tunnel）
                  ├── Rails コンテナ（Puma）
                  └── PostgreSQL コンテナ
```

### セキュリティポリシー

- EC2のインバウンドは**全ポート閉鎖**（SSH含む）
- 外部アクセスはCloudflare Tunnel経由のみ
- Cloudflare Access でメール認証（OTP）による本人確認

### EC2スペック

- インスタンス型: `t4g.nano`（0.5GB）または `t4g.micro`（1GB）
- OS: Ubuntu 24.04 LTS（ARM64）
- EBS: 10〜20GB（gp3）
- Swap: **2GB必須**（特にnanoはビルド時のメモリ不足防止）

---

## 実装状況

| 機能 | 状態 |
|------|------|
| タスク管理（Tasks CRUD） | ✅ 実装済み |
| 日次レポート（DailyReports） | ✅ 実装済み |
| 2ペインレイアウト | ✅ 実装済み |
| Navbar / Flash通知 | ✅ 実装済み |
| PWA（manifest / service-worker） | 🚧 未実装または試験段階 |
| AIコーチング機能 | 📋 構想段階（未着手） |
| マルチユーザー対応 | 📋 将来対応予定（現在は単一ユーザー） |

---

## ドキュメント運用ルール

- コードを変更する際は、関連する設計ドキュメント（`CLAUDE.md` / `schema.md` / `concept.md` / `application_architecture.md`）も**同じコミットで更新**する
- 新機能の構想を追記する際は「現状: 未実装」などの一文を添える