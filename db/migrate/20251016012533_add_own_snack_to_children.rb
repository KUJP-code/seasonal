class AddOwnSnackToChildren < ActiveRecord::Migration[7.1]
  def change
    add_column :children, :own_snack, :boolean, default: false
  end
end
