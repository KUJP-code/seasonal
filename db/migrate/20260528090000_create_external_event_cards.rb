# frozen_string_literal: true

class CreateExternalEventCards < ActiveRecord::Migration[7.1]
  def change
    create_table :external_event_cards do |t|
      t.string :title, null: false
      t.string :url, null: false
      t.string :note
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.boolean :released, default: false, null: false

      t.timestamps
    end

    create_table :external_event_card_variants do |t|
      t.references :external_event_card,
                   null: false,
                   foreign_key: true,
                   index: { name: 'idx_ext_card_variants_on_card_id' }
      t.date :event_on, null: false

      t.timestamps
    end

    create_table :external_event_card_variant_schools do |t|
      t.references :external_event_card_variant,
                   null: false,
                   foreign_key: true,
                   index: { name: 'idx_ext_card_variant_schools_on_variant_id' }
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end

    add_index :external_event_card_variant_schools,
              %i[external_event_card_variant_id school_id],
              unique: true,
              name: 'idx_ext_card_variant_schools_unique'
  end
end
