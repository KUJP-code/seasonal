class CreateChildren < ActiveRecord::Migration[7.0]
  def change
    create_table :children do |t|
      t.string :name
      t.string :katakana_name
      t.string :en_name
      t.integer :category, default: 0
      t.integer :grade, default: 3
      t.date :birthday, index: true
      t.boolean :kindy, default: false
      t.string :allergies
      t.bigint :ssid
      t.string :ele_school_name
      t.integer :photos, default: 0
      t.boolean :needs_hat, default: true
      t.boolean :received_hat, default: false

      t.timestamps
    end

    add_reference :children, :parent,
                             null: true,
                             index: true
    add_foreign_key :children, :users,
                               column: :parent_id
              
    add_reference :children, :school,
                             null: true,
                             index: true,
                             foreign_key: true

    add_index :children, :ssid, unique: true
  end
end
