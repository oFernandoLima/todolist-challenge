class MakeDescriptionsRequired < ActiveRecord::Migration[8.0]
  def up
    Task.where(description: nil).update_all(description: "")
    TaskList.where(description: nil).update_all(description: "")
    change_column_null :tasks, :description, false
    change_column_null :task_lists, :description, false
  end

  def down
    change_column_null :tasks, :description, true
    change_column_null :task_lists, :description, true
  end
end
