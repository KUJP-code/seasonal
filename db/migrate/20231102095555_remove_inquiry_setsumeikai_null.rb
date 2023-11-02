class RemoveInquirySetsumeikaiNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :inquiries, :setsumeikai_id, true
  end
end
