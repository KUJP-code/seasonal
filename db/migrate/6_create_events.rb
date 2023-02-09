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

    add_reference :events, :member_price,
                           null: true
    add_foreign_key :events, :price_lists,
                              column: :member_price_id
    add_reference :events, :non_member_price,
                           null: true
    add_foreign_key :events, :price_lists,
                             column: :non_member_price_id
  end
end
