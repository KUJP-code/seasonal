class AddCustomerConfirmedToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :customer_confirmed, :boolean, default: false
  end
end
