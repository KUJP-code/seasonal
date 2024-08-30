class ChangeTimeSlotDefaults < ActiveRecord::Migration[7.1]
  def change
    # Timezones on DB make this weird, should end up as 10am/1:30pm/2pm in form
    change_column_default :time_slots, :start_time, from: nil, to: '2022-02-02 1:00:00'
    change_column_default :time_slots, :end_time, from: nil, to: '2022-02-02 4:30:00'
    change_column_default :time_slots, :close_at, from: '2024-01-05 06:54:41',
                                                  to: '2022-02-01 5:00:00'
  end
end
