# frozen_string_literal: true

# デイリープランニング画面コントローラー
class DailyPlanningController < ApplicationController
  def edit
    # 今日一日のレポートを取得、なければ今日の日付で新しく作る(UPSERT準備)
    @daily_report = DailyReport.find_or_initialize_by(report_on: Date.today)

    # ステータスごとにタスクを分類して取得
    # priority_group や sort_order で並べ替えておくと使いやすいです
    @backlog_tasks = Task.where(status: :backlog).order(:priority_group, :sort_order)
    @today_tasks = Task.where(status: :todo).order(:sort_order)
  end

  def update
    @daily_report = DailyReport.find_or_initialize_by(report_on: Date.today)
    
    # フォームから送られてきた値を保存
    if @daily_report.update(daily_report_params)
      redirect_to edit_daily_planning_path, notice: "プランを保存しました"
    else
      # エラー時は再描画（editで使用した変数を再取得）
      @backlog_tasks = Task.where(status: :backlog).order(:priority_group, :sort_order)
      @today_tasks = Task.where(status: :todo).order(:sort_order)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def daily_report_params
    # schema.md にある保存対象カラムを許可
    params.require(:daily_report).permit(:work_hours, :meeting_hours, :target_point)
  end
end