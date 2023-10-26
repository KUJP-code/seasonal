class AddReferrerToInquiry < ActiveRecord::Migration[7.0]
  def change
    add_column :inquiries, :referrer, :integer
  end
end
