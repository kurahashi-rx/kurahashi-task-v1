# frozen_string_literal: true

# [Tasksコントローラー]
class TasksController < ApplicationController
  # 特定のアクションを実行する前に、共通の処理(set_task)を差し込みます
  before_action :set_task, only: %i[show edit update destroy]

  # GET /tasks (Springの @GetMapping)
  def index
    # 全件取得。SQLの "SELECT * FROM tasks ORDER BY created_at DESC" を発行
    @tasks = Task.all
  end

  # GET /tasks/1
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks (Springの @PostMapping)
  def create
    @task = Task.new(task_params)

    if @task.save
      # 保存成功時。t("notice.created") は ja.yml からメッセージ取得 
      redirect_to @task, notice: t("notice.created")
    else
      # バリデーションエラー時は、HTTP 422で新規作成画面を再表示
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tasks/1
  def update
    if @task.update(task_params)
      redirect_to @task, notice: t("notice.updated")
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
    # 許可した属性のみをDB保存に利用します
    params.require(:task).permit(:title, :content, :status, :priority)
  end
end
