class AddEarlyBirdToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :early_bird_date, :date, default: Time.zone.yesterday
    add_column :events, :early_bird_discount, :integer, default: 0
  end
end
