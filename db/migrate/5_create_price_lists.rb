class CreatePriceLists < ActiveRecord::Migration[7.0]
  def change
    create_table :price_lists do |t|
      t.string :name
      t.jsonb :courses

      t.timestamps
    end
  end
end
