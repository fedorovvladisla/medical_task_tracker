class Api::V1::TagsController < ApplicationController
  before_action :set_task

  def create
    tag = Tag.find(params[:tag_id])
    @task.tags << tag
    render json: {
      message: "тег добавлен"
    }, status: :created
  rescue AcctiveRecord::RecordNotFound
    render json: {
      error: "тег не найден"
    }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: {
      errors: e.message
    }, status: :unprocessable_content
  end

  def destroy
    task_tag = @task.task_tags.find_by(tag_id: params[:id])
    if task_tag
      task_tag.destroy
      head :no_content
    else
      render json: {
        error: "тег был не найден у этого задачи"
      }, status: :not_found
    end
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      error: "задача не найдена"
    }, status: not_found
  end
end
