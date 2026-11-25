# frozen_string_literal: true

class CreatePriceChanges < ActiveRecord::Migration[7.1]
  def change
    create_table :price_changes do |t|
      t.references :invoice, null: false, foreign_key: true
      t.integer :kind, null: false, default: 0
      t.integer :old_total, null: false
      t.integer :new_total, null: false
      t.date :attendance_month
      t.string :details
      t.datetime :seen_at
      t.references :seen_by, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :price_changes, %i[kind seen_at]
  end
end
