# frozen_string_literal: true

class SurveyResponse < ApplicationRecord
  belongs_to :child
  belongs_to :survey
end
