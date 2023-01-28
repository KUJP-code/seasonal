# frozen_string_literal: true

# Represents a child, or student, enrolled at a school and/or attending an event
# Must have a parent, and a school
class Child < ApplicationRecord
  # List associations to other models
  belongs_to :parent, class_name: 'User', optional: true
  belongs_to :school, optional: true
  has_one :regular_schedule, dependent: :destroy
  delegate :area, to: :school

  has_many :registrations, dependent: :destroy
  accepts_nested_attributes_for :registrations
  has_many :time_slots, through: :registrations,
                        source: :registerable,
                        source_type: 'TimeSlot'
  has_many :options, through: :registrations,
                     source: :registerable,
                     source_type: 'Option'
  has_many :events, -> { distinct }, through: :time_slots

  # Track changes with PaperTrail
  has_paper_trail

  # Map level integer in table to a level
  enum :level, unknown: 0,
               kindy: 1,
               land_low: 2,
               land_high: 3,
               sky_low: 4,
               sky_high: 5,
               galaxy_low: 6,
               galaxy_high: 7,
               keep_up: 8,
               specialist: 9,
               tech_up: 10

  # Map category int in table to a category
  enum :category, internal: 0,
                  reservation: 1,
                  external: 2

  # Validations
  validates :ja_first_name, :ja_family_name, :katakana_name, :en_name, presence: true

  validates :ja_first_name, :ja_family_name, format: { with: /[一-龠]+|[ぁ-ゔ]+|[ァ-ヴー]+|[々〆〤ヶ]+/u }
  validates :katakana_name, format: { with: /[ァ-ヴー]/u }
  validates :en_name, format: { with: /[A-Za-z '-]/ }

  validates :birthday, comparison: { greater_than: 13.years.ago, less_than: 2.years.ago }
  validates :ssid, uniqueness: true

  # Scopes for broad levels
  scope :elementary, -> { where(level: [2, 3, 4, 5, 6, 7, 8, 9, 10]) }
  scope :evening_only, -> { where(level: [8, 9, 10]) }
  scope :land, -> { where(level: [2, 3]) }
  scope :sky, -> { where(level: [4, 5]) }
  scope :galaxy, -> { where(level: [5, 6]) }

  # Scopes for children who attend certain days
  scope :attend_monday, -> { joins(:regular_schedule).where('regular_schedule.monday' => true) }
  scope :attend_tuesday, -> { joins(:regular_schedule).where('regular_schedule.tuesday' => true) }
  scope :attend_wednesday, -> { joins(:regular_schedule).where('regular_schedule.wednesday' => true) }
  scope :attend_thursday, -> { joins(:regular_schedule).where('regular_schedule.thursday' => true) }
  scope :attend_friday, -> { joins(:regular_schedule).where('regular_schedule.friday' => true) }

  # Model methods
  def name
    "#{ja_family_name} #{ja_first_name}"
  end

  def diff_school_events
    events.where.not(school: school).distinct
  end

  def opt_registrations
    registrations.where(registerable_type: 'Option')
  end

  def registered?(registerable)
    registrations.find_by(registerable: registerable)
  end

  def slot_registrations
    registrations.where(registerable_type: 'TimeSlot')
  end
end
