# frozen_string_literal: true

class Survey < ApplicationRecord
  validates :name, :questions, presence: true

  def criteria_match?(child)
    valid_criteria = criteria.reject { |_k, v| v.empty? }
    valid_criteria.all? { |k, v| v == child[k] }
  end
end
