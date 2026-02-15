class CreateDailyReports < ActiveRecord::Migration[7.2]
  def change
    create_table :daily_reports do |t|
      t.date :report_on
      t.float :work_hours
      t.float :meeting_hours
      t.integer :target_point
      t.integer :actual_point
      t.text :reflection
      t.text :comment

      t.timestamps
    end
    add_index :daily_reports, :report_on
  end
end
