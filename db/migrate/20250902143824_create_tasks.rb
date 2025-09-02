class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :title
      t.integer :priority
      t.boolean :completed
      t.integer :status
      t.references :task_list, null: false, foreign_key: true

      t.timestamps
    end
  end
end
