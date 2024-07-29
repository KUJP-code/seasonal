class AddReleasedToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :released, :boolean, default: true
  end
end
