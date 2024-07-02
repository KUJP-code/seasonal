class AddOtherDescriptionToDocumentUploads < ActiveRecord::Migration[7.1]
  def change
    add_column :document_uploads, :other_description, :string
  end
end
