class AddFirstSeasonalToChild < ActiveRecord::Migration[7.0]
  change_table :children do |t|
    t.boolean :first_seasonal, default: true
  end
end
