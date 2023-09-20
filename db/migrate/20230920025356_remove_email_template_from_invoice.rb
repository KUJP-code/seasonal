class RemoveEmailTemplateFromInvoice < ActiveRecord::Migration[7.0]
  change_table :invoices do |t|
    t.remove :email_template, :billing_date
  end
end
