class Task < ApplicationRecord
  belongs_to :task_list

  attribute :status, :integer, default: 0
  enum :status, { todo: 0, doing: 1, done: 2 }

  validates :title, presence: true
  validates :priority, presence: true
  validates :status, presence: true
  validates :description, length: { maximum: 10_000 }, allow_blank: true
end
