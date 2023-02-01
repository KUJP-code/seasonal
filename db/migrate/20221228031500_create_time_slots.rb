class CreateTimeSlots < ActiveRecord::Migration[7.0]
  def change
    create_table :time_slots do |t|
      t.string :name
      t.datetime :start_time
      t.datetime :end_time
      t.string :description
      t.integer :max_attendees
      t.integer :cost
      t.datetime :registration_deadline
      t.boolean :morning, default: false
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end

    add_index :time_slots, :morning
  end
end
