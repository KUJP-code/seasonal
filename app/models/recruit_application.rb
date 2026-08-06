# frozen_string_literal: true

class RecruitApplication < ApplicationRecord
  PRIVACY_POLICY_URL = 'https://www.p-up.world/privacypolicy/'

  ROLES = %w[sm bilingual native driver tour_staff new_graduate].freeze
  ABUSIVE_NATIONALITY_TERMS = %w[nigeria nigerian zambia cameroon cameroonian zimbabwean zimbabwe
                                 kenya ghana ghanian srilanka].freeze
  ABUSIVE_NATIONALITY_REASON = 'Spam origin detected'

  has_paper_trail

  validates :role, inclusion: { in: ROLES }
  validates :email, :phone, :full_name, :date_of_birth, :full_address,
            presence: true
  validates :privacy_policy_consent,
            acceptance: { accept: [true, 'true', 1, '1', 'on'] }

  before_validation :normalize_role
  before_validation :normalize_tracking_link_slug
  before_validation :set_privacy_policy_url
  before_validation :quarantine_abusive_nationality, on: :create

  scope :latest_first, -> { order(created_at: :desc) }
  scope :visible_to_hr, -> { where(quarantined: false) }
  scope :quarantine, -> { where(quarantined: true) }
  validate :tracking_link_slug_must_be_managed

  def age
    return if date_of_birth.blank?

    today = Time.zone.today
    years = today.year - date_of_birth.year
    years -= 1 if today < date_of_birth.advance(years:)
    years
  end

  private

  def quarantine_abusive_nationality
    normalized = nationality.to_s.unicode_normalize(:nfkc)
                            .downcase.gsub(/[^a-z]/, '')
    return unless ABUSIVE_NATIONALITY_TERMS.any? { |term| normalized.include?(term) }

    self.quarantined = true
    self.quarantine_reason = ABUSIVE_NATIONALITY_REASON
    self.quarantined_at ||= Time.current
  end

  def normalize_role
    self.role = role.to_s.strip
  end

  def normalize_tracking_link_slug
    self.tracking_link_slug = tracking_link_slug.to_s.strip.presence
  end

  def tracking_link_slug_must_be_managed
    return if tracking_link_slug.blank?
    return if RecruitTrackingLink.exists?(slug: tracking_link_slug)

    errors.add(:tracking_link_slug, 'must match an existing managed tracking link')
  end

  def set_privacy_policy_url
    self.privacy_policy_url = PRIVACY_POLICY_URL if privacy_policy_url.blank?
  end
end
