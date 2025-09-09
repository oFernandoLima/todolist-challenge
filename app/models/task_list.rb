class TaskList < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy

  has_many :task_list_collaborators, dependent: :destroy
  has_many :accepted_task_list_collaborators,
         -> { accepted },
         class_name: "TaskListCollaborator"
  has_many :collaborators,
         through: :accepted_task_list_collaborators,
         source: :user

  # Retorna o registro de colaboração aceito para o user
  def collaborator_record_for(user)
    return nil unless user
    accepted_task_list_collaborators.find { |c| c.user_id == user.id }
  end

  # String de permissão: owner | viewer | editor | admin | nil
  def permission_for(user)
    return nil unless user
    return "owner" if owner?(user)
    collaborator_record_for(user)&.permission_level
  end

  def owner?(user)
    user && user.id == user_id
  end

  def can_view?(user)
    return false unless user
    owner?(user) || collaborator_record_for(user).present?
  end

  # Editar tarefas (owner, editor, admin)
  def can_edit_tasks?(user)
    return false unless user
    return true if owner?(user)
    collab = collaborator_record_for(user)
    collab&.can_edit_tasks? || false
  end

  # Editar lista (mesma regra de tarefas por enquanto)
  def can_edit?(user)
    can_edit_tasks?(user)
  end

  # Excluir tarefas (owner ou admin)
  def can_delete_tasks?(user)
    return false unless user
    return true if owner?(user)
    collab = collaborator_record_for(user)
    collab&.admin? || false
  end

  # Gerenciar colaboradores (owner ou admin)
  def can_manage_collaborators?(user)
    return false unless user
    return true if owner?(user)
    collaborator_record_for(user)&.can_manage_collaborators? || false
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
