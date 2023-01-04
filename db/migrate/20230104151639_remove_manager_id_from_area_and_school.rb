class RemoveManagerIdFromAreaAndSchool < ActiveRecord::Migration[7.0]
  def change
    remove_column :schools, :manager_id
    remove_column :areas, :manager_id
  end
end
