# frozen_string_literal: true

module TimeSlotsHelper
  def name_date(slot)
    base = "#{slot.name} (#{ja_date(slot.start_time)})"
    return base if slot.morning

    "#{base} (午後)"
  end

  def times(slot)
    "#{f_time(slot.start_time)} - #{f_time(slot.end_time)}"
  end
end
