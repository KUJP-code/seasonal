class CreateChildren < ActiveRecord::Migration[7.0]
  def change
    create_table :children do |t|
      t.date :birthday
      t.integer :level, default: 0
      t.string :allergies

      t.timestamps
    end

    add_reference :children, :parent,
                             null: false,
                             index: true
    add_foreign_key :children, :users,
                               column: :parent_id
                               
    add_reference :children, :school,
                             null: true,
                             index: true,
                             foreign_key: true
  end
end
