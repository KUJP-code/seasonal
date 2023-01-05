class CreateOptions < ActiveRecord::Migration[7.0]
  def change
    create_table :options do |t|
      t.string :name
      t.string :description
      t.integer :cost

      t.timestamps
    end
  end
end
