# frozen_string_literal: true

class ChildImport < ApplicationRecord
  STATUSES = %w[queued processing completed completed_with_errors failed].freeze

  belongs_to :user
  has_one_attached :source_file

  validates :status, inclusion: { in: STATUSES }

  def finished?
    status.in?(%w[completed completed_with_errors failed])
  end
end
