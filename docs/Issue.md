# イシュ―
今後やっていきたいことや考えるべきことをメモ

## 気になっていること
- 要件定義
    - バックログメンテ
    - 振り返りはどのような機能が必要か？
    - スプリント実行はどのような機能が必要か？
    - インサイトバックログはどのようにフローに組み込むか？
- 機能開発
    - メニュー画面がイマイチ
      - トップメニューをシンプル化したほうが良い気がする
      - ナビバーの実装これでいいのか？
      - 
    - バックログメンテ機能の改善
        - タスク一覧の表示項目精査：タスク名称以外に何を表示するべきか？
        - 登録や参照項目の精緻化
    - 本番リリースに向けて必要な機能
        - 多要素認証：開発はOFF、本番はON
- CI/CD
    - フォルダ構成の見直し
        - Dockerファイルの配置をフォルダ分けしたい
- その他改善
    - 異常終了した際に発生するserver.pidファイルを起動時に削除する処理を追加
    - Docker系のコマンドを整理する
      - コンテナ操作
      - Rails操作：ログ参照とかデバッグ、DB変更、gemインストール
- 利用方法
  - PC利用のみ想定だが、スマホから利用するとした場合は何が必要だろうか？

## マイルストーンとタスク
- [ ] 1.最小機能の開発
  - [x] バックログメンテ
  - [ ] スプリントプランニング
    - [ ] スプリントプランニング画面設計
      - [ ] シナリオ定義
      - [ ] UI設計
      - [ ] データ設計
    - [ ] 画面実装
      - [ ] トップメニューからの繊維
  - [ ] ベロシティ評価、振り返り
- [ ] 2.本番環境リリース
  - まずはPCから
- [ ] 本番リリース

## 着手中のタスク：
コマンドの実行、お疲れ様です！
`daily_planning` という名称でコントローラーを作成されたとのことですので、設計書（`daily_scrum_scenario.md` および `schema.md`）の内容をこの新しい構成に流し込んでいくステップを解説します。

今回の構成では、`DailyReport`（目標設定）と `Task`（バックログ・TODOの移動）の2つのモデルを1つの画面で賢く扱うのがポイントです。

---

### 実装ステップ：デイリープランニング機能の構築

#### 1. ルーティングの整理 (`config/routes.rb`)

`generate controller` で自動追加された `get 'daily_planning/edit'` などを削除し、実態に近い「単数リソース」として定義し直します。これにより、URLが `/daily_planning/edit` とスッキリします。

```ruby
# config/routes.rb
resource :daily_planning, controller: 'daily_planning', only: [:edit, :update]

```

#### 2. モデルの実装 (`app/models/`)

設計書のロジックをモデルに持たせます。

* **DailyReportモデル:** 集中可能時間の計算
```ruby
# app/models/daily_report.rb
class DailyReport < ApplicationRecord
  def available_focus_time
    return 0.0 unless work_hours && meeting_hours
    work_hours - meeting_hours
  end
end

```


* **Taskモデル:** Enumとスコープの設定
```ruby
# app/models/task.rb
class Task < ApplicationRecord
  enum :status, { backlog: "backlog", todo: "todo", doing: "doing", done: "done" }, prefix: true

  scope :for_backlog, -> { where(status: :backlog).order(:sort_order) }
  scope :for_today, -> { where(status: :todo).order(:sort_order) }
end

```



#### 3. コントローラーの実装 (`app/controllers/daily_planning_controller.rb`)

シーケンス図にある「データの取得と保存」を実装します。

```ruby
class DailyPlanningController < ApplicationController
  def edit
    # 今日一日のレポートを取得、なければ初期化
    @daily_report = DailyReport.find_or_initialize_by(report_on: Date.today)
    
    # 画面に表示するタスク群
    @backlog_tasks = Task.for_backlog
    @today_tasks = Task.for_today
  end

  def update
    @daily_report = DailyReport.find_or_initialize_by(report_on: Date.today)
    
    if @daily_report.update(daily_report_params)
      # 必要に応じてタスクのステータス更新ロジックをここに書く
      redirect_to edit_daily_planning_path, notice: "プランを保存しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def daily_report_params
    params.require(:daily_report).permit(:work_hours, :meeting_hours, :target_point)
  end
end

```

#### 4. ビューの構築 (`app/views/daily_planning/edit.html.erb`)

画面設計メモに基づき、UIを構築します。

1. **リソース入力セクション:** `work_hours`, `meeting_hours` の入力フォーム
2. **目標設定セクション:** `target_point` の入力
3. **タスク選択セクション:** * 左側：`@backlog_tasks` をループで表示
* 右側：`@today_tasks` をループで表示



---

### シニア・アドバイス：ここからの進め方

**まずはJS（ドラッグ＆ドロップ）を入れずに作る**
最初は、チェックボックスと「保存ボタン」でタスクのステータスを `backlog` から `todo` に変えるだけのシンプルな実装から始めることを強くお勧めします。
Railsの基本機能で「データが正しく更新されること」を確認してから、リッチなUI（ドラッグ＆ドロップやHotwire）を追加すると、デバッグが非常に楽になります。

次は、**Viewの具体的なHTML構造（Tailwindなどを使ったレイアウト）**について一緒に考えましょうか？それともモデルのテストコードから固めますか？