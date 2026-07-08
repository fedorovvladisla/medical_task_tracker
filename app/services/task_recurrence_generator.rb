class TaskRecurrenceGenerator
  def self.call(task, from_date, to_date)
    new(task, from_date, to_date).generate
  end

  def initialize(task, from_date, to_date)
    @task = task
    @from = from_date
    @to = to_date
  end

  def generate
    return [] if @task.start_date.blank?
    case @task.recurrence_type
    when 'daily'
      daily_dates
    when 'monthly'
      monthly_dates
    when 'specific_dates'
      specific_dates
    when 'even_odd'
      even_odd_dates
    else
      [@task.start_date].select { |d| d >= @from && d <= @to }
    end
  end

  private

  def daily_dates
    step = @task.recurrence_interval || 1
    dates = []
    current = @task.start_date
    while current <= @to && (@task.end_date.nil? || current <= @task.end_date)
      dates << current if current >= @from
      current += step.days
    end
    dates
  end

  def monthly_dates
    day = @task.recurrence_day_of_month || 1
    (@from..@to).select do |d|
      d.day == day && d >= @task.start_date &&
        (@task.end_date.nil? || d <= @task.end_date)
    end
  end

  def specific_dates
    @task.recurrence_dates.select do |d|
      d >= @from && d <= @to &&
        d >= @task.start_date &&
        (@task.end_date.nil? || d <= @task.end_date)
    end
  end

  def even_odd_dates
    parity = @task.recurrence_even_odd == 0 ? :even? : :odd?
    (@from..@to).select do |d|
      d.send(parity) && d >= @task.start_date &&
        (@task.end_date.nil? || d <= @task.end_date)
    end
  end
end