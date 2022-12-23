# frozen_string_literal: true

class Child < ApplicationRecord
  belongs_to :parent, class_name: 'User'
  belongs_to :school

  # Map level integer in db to a string
  enum :level, unknown: 0,
               kindy: 1,
               land_lo: 2,
               land_hi: 3,
               sky_lo: 4,
               sky_hi: 5,
               galaxy_lo: 6,
               galaxy_hi: 7,
               keep_up: 8,
               specialist: 9,
               tech_up: 10

  validates :birthday, comparison: { greater_than: 13.years.ago, less_than: 2.years.ago }
end
