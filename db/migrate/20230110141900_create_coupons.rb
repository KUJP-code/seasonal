class CreateCoupons < ActiveRecord::Migration[7.0]
  def change
    create_table :coupons do |t|
      t.string :code
      t.string :name
      t.string :description
      t.decimal :discount, precision: 3, scale: 2
      t.boolean :combinable, default: false
      t.references :couponable, null: false, polymorphic: true

      t.timestamps
    end
  end
end
