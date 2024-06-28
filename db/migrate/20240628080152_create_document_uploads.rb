class CreateDocumentUploads < ActiveRecord::Migration[7.1]
  def change
    create_table :document_uploads do |t|
      t.string :child_name
      t.references :school, null: false, foreign_key: true
      t.integer :category

      t.timestamps
    end
  end
end
