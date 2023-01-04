class RemoveUnneededNullValidations < ActiveRecord::Migration[7.0]
  def change
    change_column_null :areas, :manager_id, true
    change_column_null :children, :school_id, true
    change_column_null :schools, :manager_id, true
    change_column_null :schools, :area_id, true
  end
end
