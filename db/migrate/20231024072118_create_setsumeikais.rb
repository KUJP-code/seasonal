class CreateSetsumeikais < ActiveRecord::Migration[7.0]
  def change
    create_table :setsumeikais do |t|
      t.datetime :start
      t.datetime :finish
      t.integer :attendance_limit
      t.integer :inquiries_count, default: 0
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
