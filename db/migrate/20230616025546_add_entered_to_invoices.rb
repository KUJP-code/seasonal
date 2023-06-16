class AddEnteredToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :entered, :boolean, default: false
  end
end
