class CreateRegularSchedules < ActiveRecord::Migration[7.0]
  def change
    create_table :regular_schedules do |t|
      t.boolean :monday, default: false
      t.boolean :tuesday, default: false
      t.boolean :wednesday, default: false
      t.boolean :thursday, default: false
      t.boolean :friday, default: false
      t.references :child, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
