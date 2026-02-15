class CreateTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :tasks do |t|
      t.string :status
      t.string :category
      t.string :title
      t.text :value
      t.text :definition_of_done
      t.text :procedures
      t.string :priority_group
      t.integer :story_point
      t.integer :sort_order
      t.date :completed_on

      t.timestamps
    end
  end
end
