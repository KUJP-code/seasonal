# frozen_string_literal: true

# Represents an area containing many schools
# Must have an area manager
class Area < ApplicationRecord
  has_many :schools, dependent: nil
  has_many :users, through: :schools
  has_many :children, through: :schools
  has_many :events, through: :schools
  has_many :time_slots, through: :events
  has_many :registrations, through: :time_slots

  belongs_to :manager, class_name: 'User'

  validates :name, presence: true
  validate :manager, :area_manager?

  private

  def area_manager?
    return false unless manager
    return false unless manager.role == :area_manager

    true
  end
end
