# frozen_string_literal: true

class DailyReport < ApplicationRecord
  # --- バリデーション (Springの @NotBlank や @Size に相当) ---
  # presence: true は「必須入力」、length: { maximum: 20 } は「最大20文字」
  validates :report_on, presence: true

  # --- Enum定義 ---

  # --- i18nを利用した表示用メソッド ---
end
