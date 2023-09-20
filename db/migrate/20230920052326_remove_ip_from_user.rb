class RemoveIpFromUser < ActiveRecord::Migration[7.0]
  change_table :users do |t|
    t.remove :ip
  end
end
