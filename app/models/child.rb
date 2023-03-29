# frozen_string_literal: true

# Represents a child, or student, enrolled at a school and/or attending an event
# Must have a parent, and a school
class Child < ApplicationRecord
  # Allow use of separate fields to ensure consistent name formatting
  attr_accessor :first_name, :family_name, :kana_first, :kana_family

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

  before_validation :set_name, :set_kana

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

  # Map grade int in table to a grade
  enum :grade, '満１歳' => 0,
               '満２歳' => 1,
               '年々少' => 2,
               '年少' => 3,
               '年中' => 4,
               '年長' => 5,
               '小１' => 6,
               '小２' => 7,
               '小３' => 8,
               '小４' => 9,
               '小５' => 10,
               '小６' => 11,
               '中学１年' => 12,
               '中学２年' => 13

  # Validations
  validates :birthday, comparison: { greater_than: 15.years.ago, less_than: 1.year.ago }
  validates :ssid, uniqueness: { allow_blank: true }

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

  private

  def set_kana
    # Guard clause should never happen in prod because required field, but does
    # when directly modifying after creation in seeds file
    return if kana_first.nil? && kana_family.nil?

    self.katakana_name = [kana_first.strip, kana_family.strip].join(' ')
  end

  def set_name
    # Guard clause should never happen in prod because required field, but does
    # when directly modifying after creation in seeds file
    return if first_name.nil? && family_name.nil?

    self.name = [first_name.strip, family_name.strip].join(' ')
  end
end
