class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.integer :status, default: 0, null: false
      t.date :start_date
      t.date :end_date
      t.integer :recurrence_type
      t.integer :recurrence_interval
      t.integer :recurrence_day_of_month
      t.date :recurrence_dates, array: true, default: []
      t.integer :recurrence_even_odd

      t.timestamps
    end
    add_index :tasks, :status
    add_index :tasks, :start_date
  end
end
