# [Tasksヘルパー]
# ここに定義したメソッドは app/views/tasks/ 以下のERBで自動的に使えます
module TasksHelper

  # 優先度(priority)に応じたテキストカラーのCSSクラスを返す
  def priority_text_class(priority)
    case priority
    when 'p1' then 'text-red-600'    # P1: 赤
    when 'p2' then 'text-orange-500' # P2: オレンジ
    when 'p3' then 'text-blue-500'   # P3: 青
    else 'text-gray-500'
    end
  end

  # ステータス(status)に応じたバッジのCSSクラスを返す
  def status_badge_class(status)
    case status
    when 'todo' then 'bg-gray-100 text-gray-700 border border-gray-200'
    when 'doing' then 'bg-blue-50 text-blue-700 border border-blue-100'
    when 'done' then 'bg-green-50 text-green-700 border border-green-100'
    end
  end
end