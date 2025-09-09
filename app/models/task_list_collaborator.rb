class TaskListCollaborator < ApplicationRecord
  STATUSES = %w[pending accepted declined].freeze
  PERMISSION_LEVELS = %w[viewer editor admin].freeze

  belongs_to :task_list
  belongs_to :user
  belongs_to :invited_by, class_name: "User"

  validates :user_id, uniqueness: { scope: :task_list_id, message: "já é colaborador desta lista" }
  validates :permission_level, inclusion: { in: PERMISSION_LEVELS }
  validates :status, inclusion: { in: STATUSES }
  validates :invited_at, presence: true

  before_validation :set_defaults, on: :create
  validate :cannot_invite_list_owner

  # Scopes
  scope :pending,  -> { where(status: "pending") }
  scope :accepted, -> { where(status: "accepted") }
  scope :declined, -> { where(status: "declined") }

  # Predicados de status
  def pending?  = status == "pending"
  def accepted? = status == "accepted"
  def declined? = status == "declined"

  # Permissões
  def viewer? = permission_level == "viewer"
  def editor? = permission_level == "editor"
  def admin?  = permission_level == "admin"

  def can_edit?                 = editor? || admin?
  def can_edit_tasks?           = can_edit?
  def can_admin?                = admin?
  def can_manage_collaborators? = admin?

  # Ações
  def accept!  = update!(status: "accepted")
  def decline! = update!(status: "declined")

  # Nomes amigáveis
  def permission_name
    { "viewer" => "Visualizador", "editor" => "Editor", "admin" => "Administrador" }[permission_level]
  end

  def status_name
    { "pending" => "Pendente", "accepted" => "Aceito", "declined" => "Recusado" }[status]
  end

  # Acesso válido
  def active?
    accepted?
  end

  private

  def set_defaults
    self.status     ||= "pending"
    self.invited_at ||= Time.current
  end

  def cannot_invite_list_owner
    return unless task_list && user_id == task_list.user_id
    errors.add(:user, "não pode ser colaborador da própria lista")
  end
end
