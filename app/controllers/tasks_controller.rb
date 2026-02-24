# frozen_string_literal: true

# タスクメンテ画面コントローラー
class TasksController < ApplicationController
  # --------------------------------------------------------------------------------------------------
  # フィルタ（前処理）
  # 特定のアクションの「前・後・周囲」に実行される処理。before_action はまさにこれの代表格です。
  # before_action：アクションの前に実行する。データの準備（set_task）、ログインチェックなど
  # after_action：アクションの後に実行する。ログの記録、データの分析、不要な一時ファイルの削除など
  # around_action：アクションの前後に実行する。処理時間の計測、例外処理（エラーハンドリング）など
  # --------------------------------------------------------------------------------------------------

  # show, edit, update, destroyのアクション実行前に @task をセットする
  # これにより各メソッド内で Task.find(params[:id]) を書く手間を省いている
  before_action :set_task, only: %i[show edit update destroy]

  # --------------------------------------------------------------------------------------------------
  # アクション
  # 外部（URL）からのリクエストに直接対応する「窓口」となるメソッド群。index や show などがこれに当たります。
  # --------------------------------------------------------------------------------------------------

  # 一覧表示
  # GET /tasks
  def index
    # 1. フィルタリングの設定
    if params[:statuses].present?
      @selected_statuses = Array(params[:statuses]).select(&:present?)
    else
      # 初期表示：done 以外のステータスをすべて選択状態にする
      @selected_statuses = Task.statuses.keys - ["done"]
    end

    # 2. 検索・ソートのロジックを繋げていく (ここでは base_tasks や query など)
    @tasks = Task.where(status: @selected_statuses).in_priority_order

  end

  # 1件の明細表示
  # GET /tasks/1
  def show
    # Turbo Frameからのリクエスト（モーダル表示など）の場合、
    # ヘッダー/フッターを含まないコンテンツのみを返すことで高速化
    render layout: false if turbo_frame_request?
  end

  # GET /tasks/new 新規作成画面を表示
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit 編集画面を表示
  def edit
    # インプレイス編集（一覧画面内での編集）などを想定し、レイアウトをスキップ
    if turbo_frame_request?
      # もしこのリクエストが Turbo Frame からのものだったら
      # レイアウト（共通のヘッダーやフッター）を表示せずに、中身だけ返す
      render layout: false
    end
  end

  # POST /tasks 保存処理
  def create
    @task = Task.new(task_params)
    if @task.save
      # 【重要】Turbo Streamでページを切り替えずに通知を出すため flash.now を使用。通常の flash だと「次のリクエスト」までメッセージが残ってしまうため
      flash.now[:notice] = t("notice.created")

      respond_to do |format|
        format.turbo_stream # create.turbo_stream.erb を呼び出し、一覧に1行追加する処理などを行う
        format.html { redirect_to @task }
      end
    else
      # バリデーションエラー(422 Unprocessable Entity)を返すのはTurboで必須の作法
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tasks/1 タスクを1つ更新
  def update
    if @task.update(task_params)
      flash.now[:notice] = t("notice.updated")

      respond_to do |format|
        format.turbo_stream # update.turbo_stream.erb を呼び出し、該当する行だけを書き換える
        format.html { redirect_to @task }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /tasks/1 タスクを1つ削除
  def destroy
    @task.destroy

    # 削除後、一覧からその要素を消去する指示を Turbo Stream で送る
    flash.now[:notice] = t("notice.destroyed")

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to tasks_url, notice: t("notice.destroyed") }
    end
  end

  # --------------------------------------------------------------------------------------------------
  # プライベートメソッド
  # --------------------------------------------------------------------------------------------------
  private

  # リクエストパラメータからタスクデータを取得
  def set_task
    @task = Task.find(params[:id])
  end

  # --------------------------------------------------------------------------------------------------
  # ストロングパラメータ
  # Strong Parameters: 悪意のあるパラメータ（admin: trueなど）が送り込まれるのを防ぐ防波堤
  # 許可した項目以外は保存・更新されないように制限している
  # --------------------------------------------------------------------------------------------------
  def task_params
    params.require(:task).permit(
      :status,
      :category,
      :title,
      :value,
      :definition_of_done,
      :procedures,
      :priority_group,
      :story_point,
      :sort_order,
      :completed_on
    )
  end
end