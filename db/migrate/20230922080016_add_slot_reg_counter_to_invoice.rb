class AddSlotRegCounterToInvoice < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :slot_regs_count, :integer
  end
end
