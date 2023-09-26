class AddDefaultZeroToCounterCache < ActiveRecord::Migration[7.0]
  def change
    change_column_default :invoices, :slot_regs_count, from: nil, to: 0
    change_column_default :options, :registrations_count, from: nil, to: 0
    change_column_default :time_slots, :registrations_count, from: nil, to: 0
  end
end
