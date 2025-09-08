class TaskListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task_list, only: %i[show edit update destroy]

  def index
    @task_lists = current_user.task_lists.includes(:tasks).order(created_at: :desc)

    @collaborated_task_lists =
      if current_user.respond_to?(:collaborated_task_lists)
        current_user.collaborated_task_lists.includes(:tasks).order("task_lists.created_at DESC")
      else
        TaskList.joins(:task_list_collaborators)
                .where(task_list_collaborators: { user_id: current_user.id, status: "accepted" })
                .includes(:tasks)
                .order("task_lists.created_at DESC")
      end
  end

  def show
    @todo_tasks  = @task_list.tasks.where(status: :todo).order(priority: :desc, created_at: :desc)
    @doing_tasks = @task_list.tasks.where(status: :doing).order(priority: :desc, created_at: :desc)
    @done_tasks  = @task_list.tasks.where(status: :done).order(priority: :desc, created_at: :desc)

    @permission = @task_list.permission_for(current_user)
    @can_edit   = @task_list.can_edit?(current_user)
  end

  def new
    @task_list = current_user.task_lists.new(color: "#0d6efd")
  end

  def edit; end

  def create
    @task_list = current_user.task_lists.new(task_list_params)
    if @task_list.save
      redirect_to @task_list, notice: "Task list was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @task_list.update(task_list_params)
      redirect_to @task_list, notice: "Task list was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task_list.destroy
    redirect_to task_lists_url, notice: "Task list was successfully destroyed."
  end

  def update_task_status
    @task_list =
      current_user.task_lists.find_by(id: params[:id]) ||
      current_user.collaborated_task_lists.find_by(id: params[:id])
    head :forbidden and return unless @task_list&.can_edit?(current_user)

    task = @task_list.tasks.find(params[:task_id])
    new_status = params[:status].to_s
    if Task.statuses.key?(new_status) && task.update(status: new_status)
      render json: { success: true, status: task.status }
    else
      render json: { success: false, errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_task_list
    @task_list =
      current_user.task_lists.find_by(id: params[:id]) ||
      current_user.collaborated_task_lists.find_by(id: params[:id]) ||
      TaskList.joins(:task_list_collaborators)
              .where(task_list_collaborators: { user_id: current_user.id, status: "accepted" })
              .find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound unless @task_list
  end

  def task_list_params
    params.require(:task_list).permit(:name, :description, :color)
  end
end
