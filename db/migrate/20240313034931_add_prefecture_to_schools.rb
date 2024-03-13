class AddPrefectureToSchools < ActiveRecord::Migration[7.1]
  def change
    add_column :schools, :prefecture, :string
  end
end
