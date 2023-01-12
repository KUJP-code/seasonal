# frozen_string_literal: true

# Represents an area containing many schools
# Must have an area manager
class Area < ApplicationRecord
  has_many :schools, dependent: nil
  has_many :users, through: :schools
  has_many :children, through: :schools
  has_many :events, -> { distinct }, through: :schools
  has_many :time_slots, through: :events
  has_many :options, through: :time_slots
  has_many :option_registrations, through: :time_slots
  has_many :registrations, through: :time_slots
  has_many :managements, as: :manageable,
                         dependent: :destroy
  has_many :managers, through: :managements

  validates :name, presence: true
  validate :managers, :area_manager?, unless: -> { managers.empty? }

  private

  def area_manager?
    return false unless managers || managers.all(&:area_manager?)

    true
  end
end
