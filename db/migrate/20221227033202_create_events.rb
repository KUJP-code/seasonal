class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :name
      t.string :description
      t.date :start_date
      t.date :end_date
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
