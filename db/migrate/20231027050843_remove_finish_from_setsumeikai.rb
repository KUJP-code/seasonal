class RemoveFinishFromSetsumeikai < ActiveRecord::Migration[7.0]
  def change
    remove_column :setsumeikais, :finish, :datetime
  end
end
