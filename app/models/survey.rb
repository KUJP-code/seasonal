# frozen_string_literal: true

class Survey < ApplicationRecord
  has_many :survey_responses, dependent: :destroy

  validates :name, :questions, presence: true

  def criteria_match?(child)
    valid_criteria = criteria.reject { |_k, v| v.to_s.empty? }
    return false if valid_criteria.empty? || siblings_answered?(child)

    valid_criteria.all? { |k, v| v.to_s == child[k].to_s }
  end

  private

  def siblings_answered?(child)
    child.siblings.any? { |s| s.survey_responses.ids.include?(id) }
  end
end
