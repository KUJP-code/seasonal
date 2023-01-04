# frozen_string_literal: true

class Area < ApplicationRecord
  has_many :schools, dependent: nil
  has_many :users, through: :schools
  has_many :children, through: :schools
  has_many :events, through: :schools
  has_many :time_slots, through: :events
  has_many :registrations, through: :time_slots

  belongs_to :manager, class_name: 'User'

  validates :name, presence: true
end
