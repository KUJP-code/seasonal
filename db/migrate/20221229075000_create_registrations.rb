class CreateRegistrations < ActiveRecord::Migration[7.0]
  def change
    create_table :registrations do |t|
      t.references :child, null: false, foreign_key: true
      t.references :registerable, null: false, polymorphic: true
      t.references :invoice, null: false, foreign_key: true

      t.timestamps
    end

    add_index :registrations, %i[registerable_id child_id registerable_type],
                              unique: true,
                              name: "idx_reg_per_child"
  end
end
