class AddDetailsToSchool < ActiveRecord::Migration[7.0]
  def change
    add_column :schools, :details, :jsonb
  end
end
