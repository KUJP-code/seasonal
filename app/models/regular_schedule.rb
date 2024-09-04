# frozen_string_literal: true

# Controls data for a child's usual schedule
class RegularSchedule < ApplicationRecord
  belongs_to :child

  acts_as_copy_target

  def days
    "#{'月, ' if monday}#{'火, ' if tuesday}#{'水, ' if wednesday}" \
    "#{'木, ' if thursday}#{'金' if friday}".chomp(', ')
  end

  def en_days
    {
      'Monday' => monday,
      'Tuesday' => tuesday,
      'Wednesday' => wednesday,
      'Thursday' => thursday,
      'Friday' => friday
    }
  end
end
