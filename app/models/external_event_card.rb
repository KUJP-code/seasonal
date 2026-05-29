# frozen_string_literal: true

class ExternalEventCard < ApplicationRecord
  has_many :variants,
           -> { order(event_on: :asc) },
           class_name: 'ExternalEventCardVariant',
           dependent: :destroy,
           inverse_of: :external_event_card
  accepts_nested_attributes_for :variants,
                                allow_destroy: true,
                                reject_if: :blank_variant?

  validates :title, :url, :starts_on, :ends_on, :variants, presence: true
  validates_comparison_of :ends_on, greater_than_or_equal_to: :starts_on
  validate :schools_are_unique_across_variants

  scope :active, -> { where(active: true) }
  scope :visible_on, ->(date) { where('starts_on <= ? AND ends_on >= ?', date, date) }

  def self.visible_for(child, date = Time.zone.today)
    return none unless child&.school_id

    visible_on(date)
      .active
      .joins(variants: :schools)
      .where(schools: { id: child.school_id })
      .includes(variants: [
                  :schools,
                  { image_attachment: :blob, avif_attachment: :blob }
                ])
      .distinct
      .order(starts_on: :desc, title: :asc)
  end

  def variant_for(child)
    return nil unless child&.school_id

    variants.joins(:schools)
            .where(schools: { id: child.school_id })
            .includes(image_attachment: :blob, avif_attachment: :blob)
            .first
  end

  private

  def blank_variant?(attributes)
    attributes['event_on'].blank?
  end

  def schools_are_unique_across_variants
    selected_school_ids = variants.reject(&:marked_for_destruction?)
                                  .flat_map(&:school_ids)
                                  .compact_blank
    duplicate_school_ids = selected_school_ids.tally.select { |_id, count| count > 1 }.keys
    return if duplicate_school_ids.empty?

    school_names = School.where(id: duplicate_school_ids)
                         .order(:id)
                         .map(&:name)
                         .join(', ')
    errors.add(:base, "Schools can only be assigned to one date/image set: #{school_names}")
  end
end
