class AddSendFlagToInquiries < ActiveRecord::Migration[7.0]
  def change
    add_column :inquiries, :send_flg, :boolean, default: true
    add_column :inquiries, :category, :string, default: 'R'
  end
end
