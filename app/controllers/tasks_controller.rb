class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task_list
  before_action :set_task, only: %i[show edit update destroy]
  before_action :authorize_view!
  before_action :authorize_edit!, only: %i[new create edit update destroy]

  def index
    @tasks = @task_list.tasks.order(created_at: :desc)
  end

  def show; end

  def new
    @task = @task_list.tasks.new
  end

  def create
    @task = @task_list.tasks.new(task_params)
    # Atribui o usuário somente se a associação existir (evita UnknownAttributeError)
    @task.user = current_user if @task.respond_to?(:user=)

    if @task.save
      redirect_to [ @task_list, @task ], notice: "Tarefa criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @task.update(task_params)
      redirect_to [ @task_list, @task ], notice: "Tarefa atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to task_list_path(@task_list), notice: "Tarefa removida com sucesso."
  end

  private

  def set_task_list
    @task_list =
      current_user.task_lists.find_by(id: params[:task_list_id]) ||
      current_user.collaborated_task_lists.find_by(id: params[:task_list_id]) ||
      TaskList.joins(:task_list_collaborators)
              .where(task_list_collaborators: { user_id: current_user.id, status: "accepted" })
              .find_by(id: params[:task_list_id])
    raise ActiveRecord::RecordNotFound unless @task_list
  end

  def set_task
    @task = @task_list.tasks.find(params[:id])
  end

  def authorize_view!
    unless @task_list.can_view?(current_user)
      redirect_to task_lists_path, alert: "Acesso não autorizado."
    end
  end

  def authorize_edit!
    unless @task_list.can_edit_tasks?(current_user)
      redirect_to task_list_task_path(@task_list, @task), alert: "Permissão insuficiente."
    end
  end

  def task_params
    params.require(:task).permit(:title, :priority, :status, :description)
  end
end
