class AddNotesRequestsToInquiries < ActiveRecord::Migration[7.0]
  def change
    add_column :inquiries, :notes, :string
    add_column :inquiries, :requests, :string
  end
end
