class ChangeSchoolDetailsDefaultToHash < ActiveRecord::Migration[7.1]
  def change
    change_column_default :schools, :details, from: nil, to: {}
  end
end
