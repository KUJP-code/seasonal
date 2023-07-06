class AddEmailSentToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :email_sent, :boolean, default: false
  end
end
