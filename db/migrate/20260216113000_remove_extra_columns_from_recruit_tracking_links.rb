# frozen_string_literal: true

class RemoveExtraColumnsFromRecruitTrackingLinks < ActiveRecord::Migration[7.1]
  def change
    remove_column :recruit_tracking_links, :source, :string
    remove_column :recruit_tracking_links, :campaign, :string
    remove_column :recruit_tracking_links, :notes, :text
  end
end
