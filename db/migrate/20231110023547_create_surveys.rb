class CreateSurveys < ActiveRecord::Migration[7.0]
  def change
    create_table :surveys do |t|
      t.string :name
      t.boolean :active
      t.jsonb :questions
      t.jsonb :criteria

      t.timestamps
    end
  end
end
