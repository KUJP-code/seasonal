class AddSchoolToUser < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :school, foreign_key: true, null: true
  end
end
