# frozen_string_literal: true

class AddRegularDayAfternoonPriceToPriceLists < ActiveRecord::Migration[7.1]
  def change
    add_column :price_lists, :regular_day_afternoon_price, :integer
  end
end
