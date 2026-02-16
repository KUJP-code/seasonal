# frozen_string_literal: true

class RecruitApplication < ApplicationRecord
  PRIVACY_POLICY_URL = 'https://www.p-up.world/privacypolicy/'.freeze

  ROLES = %w[sm bilingual native driver tour_staff new_graduate].freeze

  validates :role, inclusion: { in: ROLES }
  validates :email, :phone, :full_name, :date_of_birth, :full_address,
            presence: true
  validates :privacy_policy_consent,
            acceptance: { accept: [true, 'true', 1, '1', 'on'] }

  before_validation :normalize_role
  before_validation :normalize_tracking_link_slug
  before_validation :set_privacy_policy_url

  scope :latest_first, -> { order(created_at: :desc) }
  validate :tracking_link_slug_must_be_managed

  private

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
