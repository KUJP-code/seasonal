# frozen_string_literal: true

class StudentSeasonalUpdateJob < ApplicationJob
  queue_as :default

  def perform(student)
    student.update(first_seasonal: false)
  end
end
