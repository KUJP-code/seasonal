class CreateAreas < ActiveRecord::Migration[7.0]
  def change
    create_table :areas do |t|
      t.string :name

      t.timestamps
    end

    add_reference :areas, :manager, null: false, index: true
    add_foreign_key :areas, :users, column: :manager_id
  end
end
