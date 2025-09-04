class TaskListCollaboratorInvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_invitation, only: %i[accept decline]

  def index
    @invitations = current_user.task_list_collaborations
                               .includes(:task_list, :invited_by)
                               .order(invited_at: :desc)
  end

  def accept
    @invitation.accept!
    redirect_to collaboration_invites_path, notice: "Convite aceito."
  end

  def decline
    @invitation.decline!
    redirect_to collaboration_invites_path, notice: "Convite recusado."
  end

  private

  def set_invitation
    @invitation = current_user.task_list_collaborations.find(params[:id])
  end
end
