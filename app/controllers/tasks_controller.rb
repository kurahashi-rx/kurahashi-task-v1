# frozen_string_literal: true

# [Tasksコントローラー]
class TasksController < ApplicationController
  # 特定のアクションを実行する前に、共通の処理(set_task)を差し込みます
  before_action :set_task, only: %i[show edit update destroy]

  # GET /tasks (Springの @GetMapping)
  def index
    # 全件取得。優先度(priority_group)の昇順、その後作成日時(created_at)の降順でソート
    @tasks = Task.all.order(priority_group: :asc, created_at: :desc)
  end

  # GET /tasks/1
  def show
    @task = Task.find(params[:id])
      render layout: false if turbo_frame_request?
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
    # 詳細画面と同様、フレーム内更新ならレイアウトをスキップ
    render layout: false if turbo_frame_request?
  end

  # POST /tasks (Springの @PostMapping)
  def create
    @task = Task.new(task_params)
      if @task.save
        # 修正ポイント: redirect用ではなく、今すぐ出すための .now を使う
        flash.now[:notice] = t("notice.created")

        respond_to do |format|
          format.turbo_stream # create.turbo_stream.erb を探しに行く
          format.html { redirect_to @task }
        end
      else
        # バリデーションエラー時は、HTTP 422で新規作成画面を再表示
        render :new, status: :unprocessable_entity
      end
  end

  # PATCH/PUT /tasks/1
  def update
    if @task.update(task_params)
        respond_to do |format|
          format.turbo_stream # update.turbo_stream.erb を探しに行く
          format.html { redirect_to @task }
        end
    else
        render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /tasks/1
  def destroy
    @task.destroy
    redirect_to tasks_url, notice: t("notice.destroyed")
  end

  private

  def set_task
    # 共通処理：IDに基づいてレコードを1件取得 (find_by_id に相当)
    @task = Task.find(params[:id])
  end

  # Strong Parameters：セキュリティ(マスアサインメント対策)のため
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
