class TaskListCollaborator < ApplicationRecord
  belongs_to :task_list
  belongs_to :user
  belongs_to :invited_by, class_name: "User"

  validates :user_id, uniqueness: { scope: :task_list_id, message: "já é colaborador desta lista" }
  validates :permission_level, inclusion: { in: %w[viewer editor admin], message: "deve ser viewer, editor ou admin" }
  validates :status, inclusion: { in: %w[pending accepted declined], message: "deve ser pending, accepted ou declined" }
  validates :invited_at, presence: true

  validate :cannot_invite_list_owner

  scope :pending, -> { where(status: "pending") }
  scope :accepted, -> { where(status: "accepted") }
  scope :declined, -> { where(status: "declined") }
  scope :by_permission, ->(level) { where(permission_level: level) }

  before_validation :set_invited_at, on: :create

  def pending?  = status == "pending"
  def accepted? = status == "accepted"
  def declined? = status == "declined"

  def viewer? = permission_level == "viewer"
  def editor? = permission_level == "editor"
  def admin?  = permission_level == "admin"

  def can_edit?        = editor? || admin?
  def can_edit_tasks?  = can_edit?
  def can_admin?       = admin?
  def can_manage_collaborators? = admin?

  def accept!  = update!(status: "accepted")
  def decline! = update!(status: "declined")

  def permission_name
    { "viewer" => "Visualizador", "editor" => "Editor", "admin" => "Administrador" }[permission_level] || permission_level.humanize
  end

  def status_name
    { "pending" => "Pendente", "accepted" => "Aceito", "declined" => "Recusado" }[status] || status.humanize
  end

  private

  def set_invited_at
    self.invited_at ||= Time.current
  end

  def cannot_invite_list_owner
    if task_list && user == task_list.user
      errors.add(:user, "não pode ser colaborador da própria lista")
    end
  end
end
