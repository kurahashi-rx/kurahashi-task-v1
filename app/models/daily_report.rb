# frozen_string_literal: true

class DailyReport < ApplicationRecord
  # --- バリデーション (Springの @NotBlank や @Size に相当) ---
  # presence: true は「必須入力」、length: { maximum: 20 } は「最大20文字」
  validates :report_on, presence: true, uniqueness: true # 日付の重複を防ぐ
  validates :target_point, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :work_hours, :meeting_hours, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # --- Enum定義 ---

  # --- i18nを利用した表示用メソッド ---

  # --- ロジック ---
  # 期待ベロシティ計算：集中時間 1h あたり何ポイントこなせるかの基準を設ける場合に便利です
  def recommended_target_point
    (available_focus_time * 2.0).floor # 例: 集中1時間につき2pt換算など
  end

  def available_focus_time
    return 0.0 unless work_hours && meeting_hours
    work_hours - meeting_hours
  end

end
