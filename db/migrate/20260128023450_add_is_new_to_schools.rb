class AddIsNewToSchools < ActiveRecord::Migration[7.1]
  def change
    add_column :schools, :is_new, :boolean, default: false, null: false
  end
end
