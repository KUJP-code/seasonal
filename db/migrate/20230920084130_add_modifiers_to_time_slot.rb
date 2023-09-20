class AddModifiersToTimeSlot < ActiveRecord::Migration[7.0]
  change_table :time_slots do |t|
    t.integer :int_modifier, default: 0
    t.integer :ext_modifier, default: 0
    t.boolean :snack
  end
end
