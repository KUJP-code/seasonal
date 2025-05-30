# frozen_string_literal: true

class Option < ApplicationRecord
  TIME_CATEGORIES = %i[arrival departure k_arrival k_departure].freeze

  belongs_to :optionable, polymorphic: true
  delegate :event, to: :optionable
  delegate :school, to: :event
  delegate :area, to: :school

  has_many :registrations, as: :registerable,
                           dependent: :restrict_with_error
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
                  k_extension: 8,
                  plusone: 9,
                  default: :regular

  validates :name, :cost, presence: true
  validates :cost, numericality: {
    greater_than_or_equal_to: 0,
    less_than: 50_000,
    only_integer: true
  }

  # Scopes
  # For category of option
  scope :extension,   -> { where(category: :extension) }
  scope :k_extension, -> { where(category: :k_extension) }
  scope :not_time, -> { where.not(category: TIME_CATEGORIES) }
  scope :time, -> { where(category: TIME_CATEGORIES) }
  scope :any_extension, -> { where(category: %i[extension k_extension]) }
  def any_arrival?
    category == 'arrival' || category == 'k_arrival'
  end

  def any_departure?
    category == 'departure' || category == 'k_departure'
  end

  def any_extension?
    category == 'extension' || category == 'k_extension'
  end

 def extension?
   category == 'extension'
 end
 
  def time?
    TIME_CATEGORIES.include?(category.to_sym)
  end
end
