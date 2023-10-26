class CreateInquiries < ActiveRecord::Migration[7.0]
  def change
    create_table :inquiries do |t|
      t.references :setsumeikai, null: false, foreign_key: true
      t.string :parent_name
      t.string :phone
      t.string :email
      t.string :child_name
      t.date :child_birthday
      t.string :kindy
      t.string :ele_school
      t.string :planned_school
      t.date :start_date

      t.timestamps
    end
  end
end
