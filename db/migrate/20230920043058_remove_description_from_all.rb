class RemoveDescriptionFromAll < ActiveRecord::Migration[7.0]
  change_table :coupons do |t|
    t.remove :description
  end

  change_table :events do |t|
    t.remove :description
  end

  change_table :options do |t|
    t.remove :description
  end

  change_table :time_slots do |t|
    t.remove :description
  end
end
