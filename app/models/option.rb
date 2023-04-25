# frozen_string_literal: true

# Represents an option
# Time slots have many options, which can be re-used for other time slots
# and registered for by children
class Option < ApplicationRecord
  belongs_to :optionable, polymorphic: true
  delegate :event, to: :optionable
  delegate :school, to: :event
  delegate :area, to: :school

  has_many :registrations, as: :registerable,
                           dependent: :destroy
  has_many :children, through: :registrations
  has_many :coupons, as: :couponable,
                     dependent: :destroy

  # Map category integer in db to string
  enum :category, regular: 0,
                  arrival: 1,
                  departure: 2,
                  k_arrival: 3,
                  k_departure: 4,
                  meal: 5,
                  event: 6,
                  extension: 7,
                  default: :regular

  validates :name, :description, :cost, presence: true
  validates :cost, numericality: { greater_than_or_equal_to: 0, less_than: 50_000, only_integer: true }

  # Scopes
  # For category of option
  scope :time, -> { where(category: %i[arrival departure k_arrival k_departure]) }
end
