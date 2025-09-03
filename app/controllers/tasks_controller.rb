class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task_list
  before_action :set_task, only: %i[show edit update destroy]

  def index
    @tasks = @task_list.tasks.order(created_at: :desc)
  end

  def show; end

  def new
    @task = @task_list.tasks.new(status: :todo, completed: false)
  end

  def edit; end

  def create
    @task = @task_list.tasks.new(task_params)
    if @task.save
      redirect_to [ @task_list, @task ], notice: "Task was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      redirect_to [ @task_list, @task ], notice: "Task was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to task_list_path(@task_list), notice: "Task was successfully destroyed."
  end

  private

  def set_task_list
    @task_list = current_user.task_lists.find(params[:task_list_id])
  end

  def set_task
    @task = @task_list.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :priority, :completed, :status)
  end
end
