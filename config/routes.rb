Rails.application.routes.draw do
# =================================================================
# 1. タスク管理・基本設定
# =================================================================
=begin
  resources (複数形) 
    一般的なデータの塊（コレクション）を扱うための構文です。
    今回のケース: タスクは世の中にたくさん存在し、それぞれをIDで区別する必要があるため、複数形が適しています。
  引数の意味
    :tasks は、対応するコントローラー名（TasksController）とURL上の名前を決定します。
  挙動
    IDが必要: 特定のデータ操作（表示・編集・削除）を行う際、/tasks/1 のように常に :id をURLに含みます。
    7つの基本ルート: index, show, new, create, edit, update, destroy のすべてが自動生成されます。
  URL
    編集: /tasks/:id/edit (例: /tasks/1/edit)
    更新: /tasks/:id (PATCHメソッド)
  ヘルパー
    edit_task_path(@task) (引数が必要)
=end
  resources :tasks

  # =================================================================
# 2. デイリープランニング
# =================================================================
=begin
↓ 以下の2行は削除してOK。`bin/rails generate controller` で自動作成されたが、`resource` 定義がより高機能なルートを自動で作成するため
  get "daily_planning/edit"
  get "daily_planning/update"

  resource (単数形) 
    常に「今日の計画」を1つだけ扱うURLになります。
    edit_daily_planning_path => /daily_planning/edit (編集画面)
    daily_planning_path      => /daily_planning      (更新処理・PATCH)
  引数の意味
    :daily_planning: URLのベース名になります。
    only: [:edit, :update]: 自動生成されるルートを絞り込みます。今回は「計画の表示（index）」などは不要なため、編集と更新だけに限定しています。
    controller: :daily_planning: 通常、単数リソースはコントローラー名も単数形（DailyPlanningController）を期待しますが、明示的に指定することで確実に紐付けます。
  挙動
    IDが不要: URLに :id が含まれません。/daily_planning/edit にアクセスすると、システム側で「今日のデータ」を特定して表示する挙動になります。
    indexアクションが作られない: 複数を一覧表示する概念がないため、index ルートは生成されません。
  URL
    編集: /daily_planning/edit (IDなし)
    更新: /daily_planning (PATCHメソッド)
  ヘルパー
    edit_daily_planning_path (引数不要)
=end
    resource :daily_planning, only: [:edit, :update], controller: :daily_planning

# =================================================================
# 3. Rails標準・インフラ用 (デフォルト設定)
# =================================================================
  # アプリを開いた時の初期画面をタスク一覧に設定
  root "tasks#index"

  # ヘルスチェック用（アプリが動いているか監視ツールが確認する場所）
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA (Progressive Web App) 用の設定 from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

end

