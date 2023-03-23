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
  has_many :invoices, dependent: :destroy

  # Track changes with PaperTrail
  has_paper_trail

  # Map category int in table to a category
  # TODO: check this being different from db default is fine.
  # Logic for them being different was for direct imports from SS we want
  # internal default, but when creating in app we want external default
  enum :category, internal: 0,
                  reservation: 1,
                  external: 2,
                  default: :external

  # Validations
  validates :ja_first_name, :ja_family_name, :katakana_name, :en_name, presence: true

  validates :ja_first_name, :ja_family_name, format: { with: /\A[一-龠]+|[ぁ-ゔ]+|[ァ-ヴー]+|[々〆〤ヶ]+\z/u }
  validates :katakana_name, format: { with: /[ァ-ヴー]/u }
  validates :en_name, format: { with: /[A-Za-z '-]/ }

  validates :birthday, comparison: { greater_than: 15.years.ago, less_than: 1.year.ago }
  validates :ssid, uniqueness: { allow_blank: true }

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
  def arrival_time(slot)
    arr_opt = options.find_by(optionable: slot, category: :arrival)
    return slot.start_time.strftime('%I:%M%p') if arr_opt.nil?

    (slot.start_time + arr_opt.modifier.minutes).strftime('%I:%M%p')
  end

  def departure_time(slot)
    dep_opt = options.find_by(optionable: slot, category: :departure)
    return slot.end_time.strftime('%I:%M%p') if dep_opt.nil?

    (slot.end_time + dep_opt.modifier.minutes).strftime('%I:%M%p')
  end

  def diff_school_events
    events.where.not(school: school).distinct
  end

  def full_days(event, invoice_slot_ids)
    full_days = time_slots.where(id: invoice_slot_ids, morning: true, event: event).distinct

    full_days.count { |slot| registered?(slot.afternoon_slot) }
  end

  # Checks which price list the child uses
  def member?
    return false if category == 'external'

    true
  end

  def name
    "#{ja_family_name} #{ja_first_name}"
  end

  def opt_registrations
    registrations.where(registerable_type: 'Option')
  end

  def registered?(registerable)
    return true if registrations.find_by(registerable: registerable)

    false
  end

  def slot_registrations
    registrations.where(registerable_type: 'TimeSlot')
  end
end
