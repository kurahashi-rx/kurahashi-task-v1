# [Tasksヘルパー]
# ここに定義したメソッドは app/views/tasks/ 以下のERBで自動的に使えます
module TasksHelper
  # ステータスに応じた Tailwind CSS のクラスを返すメソッド
  def status_badge_class(status)
    case status
    when 'todo'
      'bg-gray-100 text-gray-800'  # 未着手：グレー 
    when 'doing'
      'bg-blue-100 text-blue-800'  # 進行中：青 
    when 'done'
      'bg-green-100 text-green-800' # 完了：緑 
    else
      'bg-gray-100 text-gray-800'
    end
  end
end
