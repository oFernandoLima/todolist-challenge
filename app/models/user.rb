class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :task_lists, dependent: :destroy

  has_many :task_list_collaborations,
         class_name: "TaskListCollaborator",
         dependent: :destroy

  has_many :accepted_task_list_collaborations,
         -> { accepted },
         class_name: "TaskListCollaborator"

  has_many :collaborated_task_lists,
         through: :accepted_task_list_collaborations,
         source: :task_list

  def pending_collaboration_invites
    task_list_collaborations.pending
  end

  validates :name, presence: true
end
