# frozen_string_literal: true

class RecruitTrackingLink < ApplicationRecord
  has_many :recruit_applications,
           foreign_key: :tracking_link_slug,
           primary_key: :slug,
           inverse_of: false,
           dependent: :restrict_with_error

  scope :active, -> { where(active: true) }
  scope :latest_first, -> { order(created_at: :desc) }

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true,
                   format: {
                     with: /\A[a-z0-9][a-z0-9_-]*\z/,
                     message: 'must use lowercase letters, numbers, _ or -'
                   }

  before_validation :normalize_slug

  private

  def normalize_slug
    self.slug = slug.to_s.strip.downcase
  end
end
