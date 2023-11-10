# frozen_string_literal: true

class Survey < ApplicationRecord
  has_many :survey_responses, dependent: :destroy

  validates :name, :questions, presence: true

  def criteria_match?(child)
    valid_criteria = criteria.reject { |_k, v| v.empty? }
    valid_criteria.all? { |k, v| v == child[k] }
  end
end
