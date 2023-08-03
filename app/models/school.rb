# frozen_string_literal: true

# Represents a single school
# Must have a school manager
class School < ApplicationRecord
  belongs_to :area

  has_many :managements, as: :manageable,
                         dependent: :destroy
  has_many :managers, through: :managements
  has_many :children, dependent: nil
  has_many :invoices, through: :children
  has_many :parents, -> { distinct }, through: :children,
                                      class_name: 'User',
                                      foreign_key: :parent_id
  has_many :events, -> { order(start_date: :asc) }, dependent: :destroy,
                                                    inverse_of: :school
  has_many :time_slots, through: :events
  has_many :options, through: :time_slots
  has_many :option_registrations, through: :time_slots
  has_many :registrations, through: :time_slots

  # Validations
  validates :name, presence: true
  validate :managers, :school_manager?

  # Instance methods
  def hat_kids
    children.joins(:adjustments).where(adjustments: { reason: '帽子代(野外アクティビティに参加される方でKids UP帽子をお持ちでない方のみ)' })
  end

  def next_event
    events.where('end_date > ?', Time.zone.now).limit(1).first
  end

  private

  def school_manager?
    return false unless managers || managers.all(&:school_manager?)

    true
  end
end
