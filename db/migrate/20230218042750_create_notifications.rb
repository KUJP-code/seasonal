class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.string :link
      t.string :message
      t.boolean :read, default: false
      t.references :user, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
