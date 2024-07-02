# frozen_string_literal: true

class DocumentUpload < ApplicationRecord
  VALID_CONTENT_TYPES = %w[
    image/png
    image/jpg
    image/jpeg
    application/pdf
    application/msword
    image/heic
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
  ].freeze

  belongs_to :school

  has_one_attached :document

  enum category: {
    schedule_change: 0,
    school_letter: 1,
    infection_report: 2,
    other: 3
  }

  validates :category, :child_name, :document, presence: true
  validate :valid_document_filetype?
  with_options if: :other? do
    validates :other_description, presence: true
  end

  private

  def valid_document_filetype?
    return false unless document.attached?
    return true if VALID_CONTENT_TYPES.include?(document.content_type)

    document.purge
    errors.add(:document, ' must be PNG, JPG, JPEG, PDF, DOC, DOCX or HEIC')
    false
  end
end
