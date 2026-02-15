# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_02_14_093459) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "daily_reports", force: :cascade do |t|
    t.date "report_on"
    t.float "work_hours"
    t.float "meeting_hours"
    t.integer "target_point"
    t.integer "actual_point"
    t.text "reflection"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["report_on"], name: "index_daily_reports_on_report_on"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "status"
    t.string "category"
    t.string "title"
    t.text "value"
    t.text "definition_of_done"
    t.text "procedures"
    t.string "priority_group"
    t.integer "story_point"
    t.integer "sort_order"
    t.date "completed_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
