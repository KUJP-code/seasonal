# frozen_string_literal: true

class PriceList < ApplicationRecord
  # Allow separate fields for courses
  attr_accessor :course1, :course3, :course5, :course10, :course15, :course20, :course25,
                :course30, :course35, :course40, :course45, :course50

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

  # Simplifies getting the list of events using a given price list
  def events
    member_events.or(non_member_events)
  end

  private

  def set_courses
    hash = {
      '1' => course1, '3' => course3, '5' => course5,
      '10' => course10, '15' => course15, '20' => course20,
      '25' => course25, '30' => course30, '35' => course35,
      '40' => course40, '45' => course45, '50' => course50
    }

    self.courses = course_prices_to_int(hash)
  end

  def course_prices_to_int(course_hash)
    course_hash.transform_values do |v|
      next if v.instance_of?(Integer)

      v.empty? ? nil : v.to_i
    end
  end
end
