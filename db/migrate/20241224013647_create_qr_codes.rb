class CreateQrCodes < ActiveRecord::Migration[7.1]
  def change
    create_table :qr_codes do |t|
      t.string :name
      t.integer :usage_count, default: 0

      t.timestamps
    end
  end
end
