class AddDefaultToSetsumeikaiInquiryCount < ActiveRecord::Migration[7.0]
  def change
    change_column_default :setsumeikais, :inquiries_count, from: nil, to: 0
  end
end
