class Task < ApplicationRecord
  belongs_to :task_list

  enum status: { todo: 0, doing: 1, done: 2 }

  validates :title, presence: true
  validates :priority, presence: true
end
