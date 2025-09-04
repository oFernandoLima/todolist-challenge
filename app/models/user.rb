class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :task_lists, dependent: :destroy

  has_many :task_list_collaborations, class_name: "TaskListCollaborator", dependent: :destroy
  has_many :collaborated_task_lists, through: :task_list_collaborations, source: :task_list

  validates :name, presence: true
end
