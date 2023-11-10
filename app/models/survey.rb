# frozen_string_literal: true

class Survey < ApplicationRecord
  validates :name, :questions, presence: true
end
