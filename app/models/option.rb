# frozen_string_literal: true

# Represents an option
# Time slots have many options, which can be re-used for other time slots
# and registered for by children
class Option < ApplicationRecord
  belongs_to :time_slot
  delegate :event, to: :time_slot
  delegate :school, to: :event
  delegate :area, to: :school

  has_many :registrations, as: :registerable,
                           dependent: :destroy
  has_many :children, through: :registrations

  validates :name, :description, :cost, presence: true
  validates :cost, comparison: { greater_than_or_equal_to: 0, less_than: 50_000 }
end
