# frozen_string_literal: true

class AddChildKatakanaNameToInquiries < ActiveRecord::Migration[7.0]
  def change
    add_column :inquiries, :child_katakana_name, :string
  end
end
