# frozen_string_literal: true

class SetsumeikaiInvolvement < ApplicationRecord
  belongs_to :school
  belongs_to :setsumeikai
end
