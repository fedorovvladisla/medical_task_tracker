class Task < ApplicationRecord
  enum :status, pending: 0, in_progress: 1, completed: 2, cancelled: 3
  enum :recurrence_type, daily: 0, monthly: 1, specific_dates: 2, even_odd: 3

  has_many :task_tags, dependent: :destroy
  has_many :tags, through: :task_tags
  has_many :task_occurrences, dependent: :destroy

  validates :title, presence: true
  validates :start_date, presence: true, if: -> { recurrence_type.present? }
  validates :recurrence_day_of_month, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 31 }, allow_nil: true
  validate :end_date_after_start_date, if: :dates_present?
  validate :recurrence_dates_present, if: :requires_specific_dates?

  def occurrences_in_range(from_date, to_date)
    return [] if from_date.blank? || to_date.blank? || start_date.blank?
    dates = TaskRecurrenceGenerator.call(self, from_date, to_date)
    occurrences_hash = task_occurrences.index_by(&:occurrence_date)
    dates.map do |date|
      occ = occurrences_hash[date]
      {
        date: date,
        status: occ&.status || status,
        overridden: occ.present?,
        overridden_date: occ&.overridden_date
      }
    end
  end

  private

  def dates_present?
    end_date.present? && start_date.present?
  end

  def requires_specific_dates?
    specific_dates? && recurrence_dates.blank?
  end

  def end_date_after_start_date
    errors.add(:end_date, "дата должна быть позже или равна началу даты") if end_date < start_date
  end

  def recurrence_dates_present
    errors.add(:recurrence_dates, "не могут поля быть пустыми для конкретной даты") if recurrence_dates.empty?
  end
end
