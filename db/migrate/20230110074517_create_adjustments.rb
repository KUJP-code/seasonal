class CreateAdjustments < ActiveRecord::Migration[7.0]
  def change
    create_table :adjustments do |t|
      t.integer :change
      t.string :reason
      t.references :invoice, foreign_key: true, null: false, index: true

      t.timestamps
    end
  end
end
