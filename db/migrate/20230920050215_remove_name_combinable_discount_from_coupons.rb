class RemoveNameCombinableDiscountFromCoupons < ActiveRecord::Migration[7.0]
  change_table :coupons do |t|
    t.remove :combinable, :discount, :name
  end
end
