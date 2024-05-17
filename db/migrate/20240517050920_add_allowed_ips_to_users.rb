class AddAllowedIpsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :allowed_ips, :jsonb, default: []
  end
end
