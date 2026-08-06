# frozen_string_literal: true

class CreateChildImports < ActiveRecord::Migration[7.1]
  def change
    create_table :child_imports do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: 'queued'
      t.integer :total_rows, null: false, default: 0
      t.integer :processed_rows, null: false, default: 0
      t.integer :created_count, null: false, default: 0
      t.integer :updated_count, null: false, default: 0
      t.integer :unchanged_count, null: false, default: 0
      t.integer :failed_count, null: false, default: 0
      t.jsonb :error_details, null: false, default: []
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end
  end
end
