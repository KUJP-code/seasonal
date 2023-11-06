class RemovePlannedSchoolFromInquiry < ActiveRecord::Migration[7.0]
  def change
    remove_column :inquiries, :planned_school, :string
  end
end
