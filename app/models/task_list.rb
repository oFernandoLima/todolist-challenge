class TaskList < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy

  has_many :task_list_collaborators, dependent: :destroy
  has_many :collaborators, through: :task_list_collaborators, source: :user

  validates :name, presence: true
  validates :color, presence: true
  validates :description, presence: true, length: { maximum: 10_000 }

  # Permissões
  def owner?(u) = u && u.id == user_id

  def collaborator_record_for(u)
    return nil unless u
    task_list_collaborators.accepted.find_by(user_id: u.id)
  end

  def permission_for(u)
    return "admin" if owner?(u) # dono é admin por padrão
    collaborator_record_for(u)&.permission_level
  end

  def can_view?(u)
    owner?(u) || collaborator_record_for(u).present?
  end

  def can_edit?(u)
    return true if owner?(u)
    collaborator_record_for(u)&.can_edit? || false
  end

  def can_manage_collaborators?(u)
    return true if owner?(u)
    collaborator_record_for(u)&.can_manage_collaborators? || false
  end

  def total_tasks_count
    tasks.count
  end

  def done_tasks_count
    tasks.respond_to?(:done) ? tasks.done.count : tasks.where(status: :done).count
  end

  def pending_tasks_count
    total_tasks_count - done_tasks_count
  end

  def completion_percentage
    return 0 if total_tasks_count.zero?
    ((done_tasks_count.to_f / total_tasks_count) * 100).round
  end

  def collaborators_count
    return 0 unless respond_to?(:collaborators)
    collaborators.count
  end
end
