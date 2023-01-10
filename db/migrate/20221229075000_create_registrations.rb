class CreateRegistrations < ActiveRecord::Migration[7.0]
  def change
    create_table :registrations do |t|
      t.integer :cost
      t.references :child, null: false, foreign_key: true
      t.references :registerable, null: false, polymorphic: true
      t.datetime :billing_date
      t.boolean :confirmed, default: false
      t.boolean :paid, default: false

      t.timestamps
    end
  end
end
