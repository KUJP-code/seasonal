# frozen_string_literal: true

class RegularSchedule < ApplicationRecord
  belongs_to :child

  def days
    "#{'月, ' if monday}#{'火, ' if tuesday}#{'水, ' if wednesday}#{'木, ' if thursday}#{'金' if friday}"
  end
end
