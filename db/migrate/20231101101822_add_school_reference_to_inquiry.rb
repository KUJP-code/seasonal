class AddSchoolReferenceToInquiry < ActiveRecord::Migration[7.0]
  def change
    add_reference :inquiries, :school, null: true, foreign_key: true
  end
end
