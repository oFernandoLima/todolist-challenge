class TaskListCollaboratorsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task_list
  before_action :require_view_permission!
  before_action :set_task_list_collaborator, only: %i[update destroy accept decline]
  before_action :require_manage_permission!, only: %i[new create update destroy]

  def index
    # @task_list já definido em before_action :set_task_list
    @accepted_collaborators = @task_list.task_list_collaborators.accepted.includes(:user, :invited_by)
    @pending_collaborators  = @task_list.task_list_collaborators.pending.includes(:user, :invited_by)
    @collaborators = @accepted_collaborators + @pending_collaborators

    existing_ids = (@collaborators.map(&:user_id) << @task_list.user_id).uniq
    @users_to_invite = User.where.not(id: existing_ids)
  end

  def new
    @task_list_collaborator = @task_list.task_list_collaborators.new(permission_level: "viewer")
    load_users
  end

  def create
    load_users
    @task_list_collaborator = @task_list.task_list_collaborators.new(
      invited_by: current_user,
      permission_level: collaborator_params[:permission_level],
      status: "pending"
    )

    user = if collaborator_params[:user_id].present?
      User.find_by(id: collaborator_params[:user_id])
    elsif collaborator_params[:email].present?
      User.find_by(email: collaborator_params[:email].to_s.strip.downcase)
    end

    unless user
      @task_list_collaborator.errors.add(:base, "Usuário não encontrado")
      return render :new, status: :unprocessable_entity
    end

    @task_list_collaborator.user = user

    if @task_list_collaborator.save
      redirect_to task_list_task_list_collaborators_path(@task_list), notice: "Convite enviado para #{user.email}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @task_list_collaborator.update(permission_level: collaborator_params[:permission_level])
      redirect_to task_list_task_list_collaborators_path(@task_list), notice: "Permissão atualizada."
    else
      redirect_to task_list_task_list_collaborators_path(@task_list), alert: @task_list_collaborator.errors.full_messages.to_sentence
    end
  end

  def destroy
    @task_list_collaborator.destroy
    redirect_to task_list_task_list_collaborators_path(@task_list), notice: "Colaborador removido."
  end

  def accept
    return redirect_to task_lists_path, alert: "Convite inválido." unless @task_list_collaborator.pending? && @task_list_collaborator.user_id == current_user.id
    @task_list_collaborator.accepted!
    redirect_to task_list_path(@task_list), notice: "Colaboração aceita."
  end

  def decline
    return redirect_to task_lists_path, alert: "Convite inválido." unless @task_list_collaborator.pending? && @task_list_collaborator.user_id == current_user.id
    @task_list_collaborator.declined!
    redirect_to task_list_collaborator_invitations_path, notice: "Convite recusado."
  end

  private

  def set_task_list
    @task_list =
      current_user.task_lists.find_by(id: params[:task_list_id]) ||
      current_user.collaborated_task_lists.find_by(id: params[:task_list_id]) ||
      TaskList.joins(:task_list_collaborators)
              .where(task_list_collaborators: { user_id: current_user.id })
              .find_by(id: params[:task_list_id])
    raise ActiveRecord::RecordNotFound unless @task_list
  end

  def set_task_list_collaborator
    @task_list_collaborator = @task_list.task_list_collaborators.find(params[:id])
  end

  def collaborator_params
    params.fetch(:task_list_collaborator, {}).permit(:user_id, :email, :permission_level)
  end

  def require_view_permission!
    head :forbidden unless @task_list.can_view?(current_user)
  end

  def require_manage_permission!
    head :forbidden unless @task_list.can_manage_collaborators?(current_user)
  end

  def load_users
    invited_ids = @task_list.task_list_collaborators.select(:user_id)
    @users = User.where.not(id: [ current_user.id, @task_list.user_id ]).where.not(id: invited_ids)
  end
end
