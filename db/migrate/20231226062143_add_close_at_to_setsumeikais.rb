class AddCloseAtToSetsumeikais < ActiveRecord::Migration[7.1]
  def change
    add_column :setsumeikais, :close_at, :datetime
  end
end
