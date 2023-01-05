class CreateSchools < ActiveRecord::Migration[7.0]
  def change
    create_table :schools do |t|
      t.string :name
      t.string :address
      t.string :phone
      t.references :area, null: true, foreign_key: true

      t.timestamps
    end
  end
end
