class CreateChildren < ActiveRecord::Migration[7.0]
  def change
    create_table :children do |t|
      t.string :ja_first_name
      t.string :ja_family_name
      t.string :katakana_name
      t.string :en_name
      t.integer :category, default: 0
      t.date :birthday, index: true
      t.integer :level, default: 0
      t.boolean :allergies
      t.string :allergy_details
      t.bigint :ssid
      t.string :ele_school_name
      t.boolean :post_photos
      t.boolean :needs_hat
      t.boolean :received_hat

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
