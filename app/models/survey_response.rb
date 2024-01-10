# frozen_string_literal: true

class SurveyResponse < ApplicationRecord
  belongs_to :child
  belongs_to :survey, counter_cache: true

  validates :answers, presence: true
end
