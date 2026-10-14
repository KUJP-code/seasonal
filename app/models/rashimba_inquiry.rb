# frozen_string_literal: true

class RashimbaInquiry < ApplicationRecord
  KINDS = { 'Sponsor inquiry' => 'sponsor',
            'Release notification' => 'release_notification' }.freeze
  CHILD_AGES = %w[0-2 3-5 6-8 9-12 13+].freeze
  SUBMISSION_KEY_FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

  enum :status, { pending: 'pending', reviewed: 'reviewed', resolved: 'resolved' }, validate: true

  before_validation :normalize_fields

  validates :kind, inclusion: { in: KINDS.values }
  validates :email, presence: true, length: { maximum: 254 },
                    format: { with: /\A[^\s@,;<>]+@[^\s@,;<>]+\.[^\s@,;<>]+\z/ }
  validates :company, :name, presence: true, if: :sponsor?
  validates :company, :name, length: { maximum: 200 }
  validates :company, :name, :email, :phone, format: { without: /[\r\n\x00]/ }
  validates :phone, length: { maximum: 40 },
                    format: { with: /\A[0-9 +().-]+\z/ }, allow_blank: true
  validates :message, :admin_notes, length: { maximum: 5000 }
  validates :message, :admin_notes, format: { without: /\x00/ }
  validates :child_age, inclusion: { in: CHILD_AGES }, allow_blank: true
  validates :privacy_consent, inclusion: { in: [true] }
  validates :consented_at, :ip_address, :submission_digest, presence: true
  validates :submission_key, format: { with: SUBMISSION_KEY_FORMAT }

  scope :latest_first, -> { order(created_at: :desc, id: :desc) }

  def sponsor?
    kind == 'sponsor'
  end

  def kind_label
    KINDS.key(kind)
  end

  private

  def normalize_fields
    %i[email company name phone child_age].each do |field|
      self[field] = self[field]&.strip
    end
    self.email = email&.downcase
  end
end
