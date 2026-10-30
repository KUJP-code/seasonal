# frozen_string_literal: true

class PriceList < ApplicationRecord
  COURSE_SIZES = %w[1 3 5 10 15 20 25 30 35 40 45 50].freeze

  # Allow separate fields for courses
  attr_accessor(*COURSE_SIZES.map { |size| "course#{size}" })

  before_validation :set_courses

  has_many :member_events, dependent: nil,
                           class_name: 'Event',
                           foreign_key: :member_prices_id,
                           inverse_of: :member_prices
  has_many :non_member_events, dependent: nil,
                               class_name: 'Event',
                               foreign_key: :non_member_prices_id,
                               inverse_of: :non_member_prices

  validates :name, :courses, presence: true
  validates :regular_day_afternoon_price,
            numericality: { only_integer: true, greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 2_147_483_647 },
            allow_nil: true

  # Simplifies getting the list of events using a given price list
  def events
    member_events.or(non_member_events)
  end

  private

  def set_courses
    hash = COURSE_SIZES.index_with { |size| public_send("course#{size}") }

    self.courses = (courses || {}).merge(course_prices_to_int(hash.compact))
  end

  def course_prices_to_int(course_hash)
    course_hash.transform_values do |v|
      next if v.instance_of?(Integer)

      v.empty? ? nil : v.to_i
    end
  end
end
