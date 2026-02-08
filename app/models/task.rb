# frozen_string_literal: true

class Task < ApplicationRecord
  # 0: todo, 1: doing, 2: done と定義
  # enum :status, { todo: 0, doing: 1, done: 2 }, default: :todo
  enum :status, { todo: 0, doing: 1, done: 2 }, default: :todo

  def status_i18n
    I18n.t("enums.task.status.#{status}")
  end

end
