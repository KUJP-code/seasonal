# frozen_string_literal: true

class AddMonthToRegularSchedules < ActiveRecord::Migration[7.1]
  def change
    # Existing schedules have no known attendance month. Preserve them without
    # guessing a month; only dated schedules are used by the monthly displays.
    add_column :regular_schedules, :month, :date
    add_index :regular_schedules, %i[child_id month], unique: true
  end
end
