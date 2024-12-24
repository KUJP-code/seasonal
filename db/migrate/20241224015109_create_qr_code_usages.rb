class CreateQrCodeUsages < ActiveRecord::Migration[7.1]
  def change
    create_table :qr_code_usages do |t|
      t.references :qr_code, null: false, foreign_key: true
      t.string :ip_address
      t.text :user_agent

      t.timestamps
    end
  end
end
