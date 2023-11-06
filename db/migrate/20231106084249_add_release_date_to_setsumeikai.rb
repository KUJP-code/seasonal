class AddReleaseDateToSetsumeikai < ActiveRecord::Migration[7.0]
  def change
    add_column :setsumeikais, :release_date, :date
  end
end
