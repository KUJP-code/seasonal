class CreateSchools < ActiveRecord::Migration[7.0]
  def change
    create_table :schools do |t|
      t.string :name
      t.string :address
      t.string :phone
      t.references :area, null: false, foreign_key: true

      t.timestamps
    end

    add_reference :schools, :manager,
                            null: false,
                            index: true
    add_foreign_key :schools, :users,
                              column: :manager_id
  end
end
