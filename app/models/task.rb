# frozen_string_literal: true

# [Taskモデル]
# ApplicationRecordを継承することで、DB操作(Active Record)が可能になります
class Task < ApplicationRecord
  # --- バリデーション (Springの @NotBlank や @Size に相当) ---
  # presence: true は「必須入力」、length: { maximum: 20 } は「最大20文字」
  validates :title, presence: true, length: { maximum: 20 }
  validates :content, presence: true
  validates :status, presence: true
  validates :priority, presence: true

  # --- Enum定義 (Springの @Enumerated に相当) ---
  # これにより、status_i18n メソッドや status.todo? などの判定メソッドが自動生成されます
  # ja.yml の enums.task.status と連動します 
  enum :status, { todo: 0, doing: 1, done: 2 }, default: :todo
  enum :priority, { p1: 0, p2: 1, p3: 2 }, default: :p1

  def status_i18n
    I18n.t("enums.task.status.#{status}")
  end

  def priority_i18n
    I18n.t("enums.task.priority.#{priority}")
  end


end