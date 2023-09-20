class AddCounterCacheToOptionsAndTimeSlots < ActiveRecord::Migration[7.0]
  def change
    add_column :options, :registrations_count, :integer
    add_column :time_slots, :registrations_count, :integer
  end
end
