class AddDescriptionToTasksAndTaskLists < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :description, :text
    add_column :task_lists, :description, :text
  end
end
