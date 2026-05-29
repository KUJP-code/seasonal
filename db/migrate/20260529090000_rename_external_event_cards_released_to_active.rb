# frozen_string_literal: true

class RenameExternalEventCardsReleasedToActive < ActiveRecord::Migration[7.1]
  def change
    rename_column :external_event_cards, :released, :active
  end
end
