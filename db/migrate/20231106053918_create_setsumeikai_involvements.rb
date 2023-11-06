class CreateSetsumeikaiInvolvements < ActiveRecord::Migration[7.0]
  def change
    create_table :setsumeikai_involvements do |t|
      t.references :school, null: false, foreign_key: true
      t.references :setsumeikai, null: false, foreign_key: true

      t.timestamps
    end
  end
end
