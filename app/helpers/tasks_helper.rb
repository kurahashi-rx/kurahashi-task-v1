# frozen_string_literal: true

# タスクヘルパー
# ここに定義したメソッドは app/views/tasks/ 以下のERBで自動的に使えます
module TasksHelper
  def status_badge_class(status)
    case status
    when 'backlog' then 'bg-gray-100 text-gray-600'
    when 'ready'   then 'bg-yellow-100 text-yellow-700'
    when 'sprint'  then 'bg-blue-100 text-blue-700'
    when 'done'    then 'bg-green-100 text-green-700'
    else ''
    end
  end

  def priority_group_text_class(priority_group)
    case priority_group
    when 'p1' then 'text-red-600'
    when 'p2' then 'text-orange-500'
    when 'p3' then 'text-green-600'
    else 'text-gray-500'
    end
  end
end
