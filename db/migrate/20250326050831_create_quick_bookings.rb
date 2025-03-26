class CreateQuickBookings < ActiveRecord::Migration[7.1]
  def change
    create_table :quick_bookings do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.references :school, null: false, foreign_key: true
      t.integer :timeslot_id
      t.integer :event_id

      t.timestamps
    end
  end
end
