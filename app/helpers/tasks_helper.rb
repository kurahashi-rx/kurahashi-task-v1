module TasksHelper
  def status_badge_class(status)
    case status
    when 'todo'
      'bg-gray-100 text-gray-800' # グレー
    when 'doing'
      'bg-blue-100 text-blue-800' # 青
    when 'done'
      'bg-green-100 text-green-800' # 緑
    else
      'bg-gray-100 text-gray-800'
    end
  end
end