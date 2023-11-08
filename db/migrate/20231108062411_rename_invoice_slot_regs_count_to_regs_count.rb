class RenameInvoiceSlotRegsCountToRegsCount < ActiveRecord::Migration[7.0]
  def change
    rename_column :invoices, :slot_regs_count, :registrations_count
  end
end
