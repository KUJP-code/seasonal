class AddPositionToSchools < ActiveRecord::Migration[7.1]
  def change
    add_column :schools, :position, :integer, default: 0
  end
end
