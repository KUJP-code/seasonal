# frozen_string_literal: true

class AddSkippedCountToChildImports < ActiveRecord::Migration[7.1]
  def change
    add_column :child_imports, :skipped_count, :integer, null: false, default: 0
  end
end
