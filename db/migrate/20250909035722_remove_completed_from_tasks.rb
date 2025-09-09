class RemoveCompletedFromTasks < ActiveRecord::Migration[8.0]
  def up
    return unless column_exists?(:tasks, :completed)
    remove_column :tasks, :completed
  end

  def down
    return if column_exists?(:tasks, :completed)
    add_column :tasks, :completed, :boolean, null: false, default: false
    add_index :tasks, :completed
  end
end
