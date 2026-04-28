# frozen_string_literal: true

class AddRecruiterPrivilegesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :recruiter_privileges, :boolean, default: false, null: false
  end
end
