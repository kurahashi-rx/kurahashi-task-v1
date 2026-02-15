# frozen_string_literal: true

class Task < ApplicationRecord
  # --- バリデーション (Springの @NotBlank や @Size に相当) ---
  validates :status, presence: true
  validates :title, presence: true, length: { maximum: 20 }
  validates :priority_group, presence: true

  # --- Enum定義 ---
  # これにより、status_i18n メソッドや status.todo? などの判定メソッドが自動生成されます

  # ステータスの定義（DBの文字列とシンボルを紐付け）
  enum :status, {
    backlog: "backlog",
    ready: "ready",
    sprint: "sprint",
    done: "done"
  }, prefix: true, default: :backlog

  enum :priority_group, {
    p1: "p1",
    p2: "p2",
    p3: "p3"
  }, prefix: true, default: :p1

  # 数値をそのままキーにする（SPは集計に使うため integer 扱い）
  # キーは文字列(point_x)、値は数値(x)
  enum :story_point, {
    point_0: 0,
    point_1: 1,
    point_3: 3,
    point_5: 5
  }, prefix: true, default: :point_1

  # --- i18nを利用した表示用メソッド ---
  # これを定義しておけば、Viewで <%= @task.status_i18n %> と呼ぶだけで日本語が出ます
  def status_i18n
    I18n.t("activerecord.enums.task.status.#{status}")
  end

  def priority_group_i18n
    I18n.t("activerecord.enums.task.priority_group.#{priority_group}")
  end

  def story_point_i18n
    # 選択されている値（例: "point_3"）を元に ja.yml から日本語を引く
    I18n.t("activerecord.enums.task.story_point.#{story_point}")
  end
end
