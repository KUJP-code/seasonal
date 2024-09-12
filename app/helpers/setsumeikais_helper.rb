# frozen_string_literal: true

module SetsumeikaisHelper
  def school_date_time(setsumeikai)
    "#{setsumeikai.school.name} #{ja_datetime(setsumeikai.start)}"
  end
end
