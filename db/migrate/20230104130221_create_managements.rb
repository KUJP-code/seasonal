class CreateManagements < ActiveRecord::Migration[7.0]
  def change
    create_table :managements do |t|
      t.references :manageable, null: false, polymorphic: true

      t.timestamps
    end

    add_reference :managements, :manager,
                                null: false,
                                index: true 
    add_foreign_key :managements, :users,
                                  column: :manager_id
  end
end
