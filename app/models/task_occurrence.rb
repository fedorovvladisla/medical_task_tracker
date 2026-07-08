class TaskOccurrence < ApplicationRecord
  belongs_to :task
  enum :status, pending: 0, in_progress: 1, completed: 2, cancelled: 3
  validates :occurrence_date, presence: true, uniqueness: { scope: :task_id }
  validates :status, presence: true

  def effective_date
    overridden_date || occurrence_date
  end
end
