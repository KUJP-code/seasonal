# frozen_string_literal: true

# Represents a child, or student, enrolled at a school and/or attending an event
# Must have a parent, and a school
class Child < ApplicationRecord
  # Set names, kindy and hat from meta-fields
  before_validation :set_name, :set_kana, :set_kindy, :set_hat

  # Allow use of separate fields to ensure consistent name formatting
  attr_accessor :first_seasonal, :first_name, :family_name, :kana_first, :kana_family

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
  has_many :invoices, dependent: :destroy
  has_many :real_invoices, -> { where('total_cost > ?', 3_000) },
                          class_name: 'Invoice',
                          dependent: nil,
                          inverse_of: :child
  has_many :events, -> { distinct }, through: :invoices
  has_many :adjustments, through: :invoices

  # Track changes with PaperTrail
  has_paper_trail

  # Allow export/import with postgres-copy
  acts_as_copy_target

  # Map category int in table to a category
  # TODO: check this being different from db default is fine.
  # Logic for them being different was for direct imports from SS we want
  # internal default, but when creating in app we want external default
  enum :category, internal: 0,
                  reservation: 1,
                  external: 2,
                  unknown: 3,
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
               '中学２年' => 13,
               '高校生以上' => 14

  # Map photos int in table to a permission
  enum :photos, 'NG' => 0,
                'マイペイジ' => 1,
                'OK' => 3,
                'Unknown' => 4

  # Validations
  # Format
  validates :katakana_name, format: { with: /\A[ァ-ヶヶ　ー ]+\z/ }

  # Inclusion
  validates :category, inclusion: { in: categories.keys }
  validates :grade, inclusion: { in: grades.keys }
  validates :photos, inclusion: { in: photos.keys }

  # Presence
  validates :allergies, :category, :en_name, :grade, :katakana_name, :name, :photos, presence: true

  # Uniqueness
  validates :ssid, uniqueness: { allow_blank: true }

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

  # Checks which price list the child uses
  def member?
    return false if external?

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

  def siblings
    return [] if parent.nil?

    parent.children.where.not(id: id)
  end

  private

  # Due to a last minute change in requirements and a reluctance on my part to
  # make database changes the day before it goes live, the needs_hat boolean is
  # now being used as a stand-in for whether the child is attending their first
  # seasonal event or not. This can be set by a parent when adding a new child,
  # or by a staff member at any time if the child is editable.
  # Will either be toggling it to false during invoice calculation when they
  # register for their second seasonal, or manually after each seasonal for kids
  # who attended
  def set_hat
    self.needs_hat = true if first_seasonal == '1'
    self.needs_hat = false if first_seasonal == '0'
  end

  def set_kana
    # Guard clause should never happen in prod because required field, but does
    # when directly modifying after creation in seeds file
    return if kana_first.nil? && kana_family.nil?

    self.katakana_name = [kana_family.strip, kana_first.strip].join(' ')
  end

  def set_kindy
    self.kindy = %w[満１歳 満２歳 年々少 年少 年中 年長].include?(grade)
  end

  def set_name
    # Guard clause should never happen in prod because required field, but does
    # when directly modifying after creation in seeds file
    return if first_name.nil? && family_name.nil?

    self.name = [family_name.strip, first_name.strip].join(' ')
  end
end
