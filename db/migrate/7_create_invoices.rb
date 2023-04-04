class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.integer :total_cost, default: 0
      t.datetime :billing_date
      t.string :summary
      t.string :email_template
      t.boolean :in_ss, default: false
      t.datetime :seen_at, default: nil

      t.timestamps
    end

    add_reference :invoices, :child,
                             null: false,
                             index: true
    add_foreign_key :invoices, :children
    
    add_reference :invoices, :event,
                             null: false,
                             index: true,
                             foreign_key: true
  end
end
