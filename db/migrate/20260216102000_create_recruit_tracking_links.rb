# frozen_string_literal: true

class CreateRecruitTrackingLinks < ActiveRecord::Migration[7.1]
  def change
    create_table :recruit_tracking_links do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :source
      t.string :campaign
      t.text :notes
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :recruit_tracking_links, :slug, unique: true
    add_index :recruit_tracking_links, :active
  end
end
