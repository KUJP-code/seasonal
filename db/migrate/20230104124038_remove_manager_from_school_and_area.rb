class RemoveManagerFromSchoolAndArea < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :schools, column: :manager_id
    remove_foreign_key :areas, column: :manager_id
  end
end
