class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.integer :total_cost
      t.datetime :billing_date
      t.string :summary
      t.boolean :in_ss, default: false
      t.boolean :paid, default: false
      t.boolean :email_sent, default: false

      t.timestamps
    end

    add_reference :invoices, :parent,
                             null: false,
                             index: true
    add_foreign_key :invoices, :users,
                               column: :parent_id
    
    add_reference :invoices, :event,
                             null: false,
                             index: true,
                             foreign_key: true
  end
end
