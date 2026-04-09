# frozen_string_literal: true

class AddHrFieldsToRecruitApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :recruit_applications, :contacted_on, :date
    add_column :recruit_applications, :interviewed, :boolean
    add_column :recruit_applications, :hr_comments, :text
  end
end
