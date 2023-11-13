# frozen_string_literal: true

class Survey < ApplicationRecord
  has_many :survey_responses, dependent: :destroy

  validates :name, :questions, presence: true

  def criteria_match?(child)
    valid_criteria = criteria.reject { |_k, v| v.to_s.empty? }
    return false if valid_criteria.empty? || answered?(child)

    valid_criteria.all? { |k, v| v.to_s == child[k].to_s }
  end

  private

  def answered?(child)
    child_answered?(child) || sibling_answered?(child)
  end

  def child_answered?(child)
    child.survey_responses.pluck(:survey_id).include?(id)
  end

  def sibling_answered?(child)
    child.siblings.any? do |s|
      s.survey_responses.pluck(:survey_id).include?(id)
    end
  end
end
