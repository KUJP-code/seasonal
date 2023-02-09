# frozen_string_literal: true

class Invoice < ApplicationRecord
  belongs_to :parent, class_name: 'User'
  has_many :children, through: :parent
  belongs_to :event

  has_many :registrations, dependent: :destroy
  accepts_nested_attributes_for :registrations

  # Validations
  validates :total_cost, presence: true
  validates :total_cost, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
