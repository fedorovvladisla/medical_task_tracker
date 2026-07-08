class Api::V1::TasksController < ApplicationController
  before_action :set_task, only: [:show, :update, :destroy]

  def index
    tasks = Task.all
    # фильтр по статусу
    tasks = tasks.where(status: params[:status]) if params[:status].present?
    # фильтр по тегу
    if params[:tag_id].present?
      tasks = tasks.joins(:tags).where(tags: { id: params[:tag_id] })
    end
    start_date = parse_date(params[:start_date]) || Date.current.beginning_of_month
    end_date   = parse_date(params[:end_date])   || Date.current.end_of_month
    render json: tasks.map { |task|
      task.as_json.merge(
        'occurrences' => task.occurrences_in_range(start_date, end_date)
      )
    }
  end

  def show
    start_date = parse_date(params[:start_date]) || Date.current.beginning_of_month
    end_date   = parse_date(params[:end_date])   || Date.current.end_of_month
    render json: @task.as_json.merge(
      'occurrences' => @task.occurrences_in_range(start_date, end_date)
    )
  end

  def create
    task = Task.new(task_params)
    if task.save
      render json: task.as_json, status: :created
    else
      render json: {
        errors: task.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      render json: @task.as_json
    else
      render json: {
        errors: @task.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    head :no_content
  end

  private

  def set_task
    @task = Task.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      error: 'задача не найдена'
    }, status: :not_found
  end

  def task_params
    params.require(:task).permit(
      :title, :description, :status, :start_date, :end_date,
      :recurrence_type, :recurrence_interval, :recurrence_day_of_month,
      :recurrence_even_odd, recurrence_dates: []
    )
  end

  def parse_date(value)
    Date.parse(value) rescue nil
  end
end
