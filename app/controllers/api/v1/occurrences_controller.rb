class Api::V1::OccurrencesController < ApplicationController
  before_action :set_task

  def update
    occurrence = @task.task_occurrences.find_or_initialize_by(occurrence_date: params[:date])
    occurrence.status = params[:status] if params[:status].present?
    occurrence.overridden_date = params[:overridden_date] if params[:overridden_date].present?
    if occurrence.save
      render json: {
        task_id: occurrence.task_id,
        date: occurrence.occurrence_date,
        status: occurrence.status,
        overridden_date: occurrence.overridden_date,
        effective_date: occurrence.effective_date
      }
    else
      render json: {
        errors: occurrence.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      error: "задача не найдена"
    }, status: :not_found
  end
end
