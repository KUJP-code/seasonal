class RemoveCustomerConfirmedFromInvoices < ActiveRecord::Migration[7.0]
  def change
    remove_column :invoices, :customer_confirmed, :boolean
  end
end
