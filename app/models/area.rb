# frozen_string_literal: true

class Area < ApplicationRecord
  belongs_to :manager, class_name: 'User'

  validates :name, presence: true
end
