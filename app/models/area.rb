# frozen_string_literal: true

class Area < ApplicationRecord
  # has_many :schools, dependent: :nil
  belongs_to :manager, class_name: 'User'

  validates :name, presence: true
end
