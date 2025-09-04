class CreateTaskListCollaborators < ActiveRecord::Migration[8.0]
  def change
    create_table :task_list_collaborators do |t|
      t.references :task_list, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.bigint :invited_by_id, null: false
      t.string :permission_level, null: false, default: "viewer"
      t.string :status, null: false, default: "pending"
      t.datetime :invited_at, null: false

      t.timestamps
    end

    add_index :task_list_collaborators, [ :task_list_id, :user_id ], unique: true
    add_foreign_key :task_list_collaborators, :users, column: :invited_by_id
  end
end
