# frozen_string_literal: true

class AddPricingBatchToRegistrations < ActiveRecord::Migration[7.1]
  def change
    add_column :registrations, :pricing_batch, :integer, default: 1, null: false
  end
end
