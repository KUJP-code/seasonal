# frozen_string_literal: true

class TimeSlot < ApplicationRecord
  after_create :create_default_opts, :create_aft_slot,
               unless: proc { |ts| ts.party? }

  attr_accessor :apply_all

  acts_as_copy_target

  belongs_to :event
  has_one :school, through: :event
  delegate :area, to: :event

  has_many :options, as: :optionable,
                     dependent: :destroy
  accepts_nested_attributes_for :options, allow_destroy: true,
                                          reject_if: :all_blank
  has_many :option_registrations, through: :options,
                                  source: :registrations
  has_many :registrations, as: :registerable,
                           dependent: :destroy
  has_many :children, through: :registrations
  has_many :coupons, as: :couponable,
                     dependent: :destroy

  belongs_to :morning_slot, class_name: 'TimeSlot', optional: true
  has_one :afternoon_slot, class_name: 'TimeSlot',
                           foreign_key: :morning_slot_id,
                           dependent: :destroy,
                           inverse_of: :morning_slot
  accepts_nested_attributes_for :afternoon_slot, allow_destroy: true,
                                                 reject_if: :name_blank?

  has_one_attached :image
  has_one_attached :avif

  validates :name, :start_time, :end_time, presence: true
  validates_comparison_of :end_time, greater_than: :start_time

  enum :category, {
    seasonal: 0,
    special: 1,
    party: 2,
    outdoor: 3
  }

  scope :afternoon, -> { where(morning: false) }
  scope :for_registration_page,
        lambda { |event|
          where(event_id: event.id, morning: true)
            .includes(:options,
                      afternoon_slot: %i[options],
                      avif_attachment: %(blob),
                      image_attachment: %i[blob])
            .order(start_time: :desc)
        }
  scope :morning, -> { where(morning: true) }

  def avif_id
    return nil if avif.blob.nil?

    avif.blob.id
  end

  def avif_id=(avif_id)
    return if avif_id.nil?

    self.avif = ActiveStorage::Blob.find(avif_id)
  end

  def closed?
    return true if closed

    if Time.zone.now > close_at
      update(closed: true)
      true
    else
      false
    end
  end

  def image_id
    return nil if image.blob.nil?

    image.blob.id
  end

  def image_id=(image_id)
    return if image_id.nil?

    self.image = ActiveStorage::Blob.find(image_id)
  end

  def same_name_slots
    event_ids = Event.where(name: event.name).ids
    TimeSlot.where(name:,
                   morning:,
                   category:,
                   event_id: event_ids)
  end

  # These convert the start/end datetimes into something more useful for display
  def date
    start_time.strftime('%m月%d日') + " #{ja_day}"
  end

  def day
    start_time.strftime('%A')
  end

  def extra_cost_for(child)
    category_cost = child.external? ? ext_modifier : int_modifier
    grade_cost = child.kindy ? kindy_modifier : ele_modifier

    category_cost + grade_cost
  end

  def f_end_time
    end_time.strftime('%I:%M%p')
  end

  def f_start_time
    start_time.strftime('%I:%M%p')
  end

  def ja_day
    en_day = start_time.strftime('%A')

    "(#{DAYS[en_day]})"
  end

  def name_date
    if morning
      "#{name} (#{date})"
    else
      "#{name} (#{date}) (午後)"
    end
  end

  def times
    "#{f_start_time} - #{f_end_time}"
  end

  private

  def create_aft_slot
    return unless morning
    return if party? || special?

    create_afternoon_slot(
      name:,
      start_time: start_time + 5.hours,
      end_time: end_time + 5.hours,
      close_at:,
      category: :seasonal,
      morning: false,
      event_id:,
      snack: true
    )
  end

  def create_default_opts
    if morning
      options.create(DEFAULT_MORN_OPTS)
      options.create(DEFAULT_SPECIAL_OPTS) if special?
    else
      options.create(DEFAULT_AFT_OPTS)
    end
  end

  def name_blank?(afternoon_slot)
    afternoon_slot[:name].blank?
  end

  DAYS = {
    'Sunday' => '日',
    'Monday' => '月',
    'Tuesday' => '火',
    'Wednesday' => '水',
    'Thursday' => '木',
    'Friday' => '金',
    'Saturday' => '土'
  }.freeze

  DEFAULT_AFT_OPTS = [
    {
      name: '夕食',
      category: :meal,
      cost: 770
    },
    {
      name: '~19:00（1コマ）',
      category: :departure,
      modifier: 30,
      cost: 460
    },
    {
      name: '~19:30（2コマ）',
      category: :departure,
      modifier: 60,
      cost: 920
    },
    {
      name: '~20:00（3コマ）',
      category: :departure,
      modifier: 90,
      cost: 1_380
    },
    {
      name: '~20:30（4コマ）',
      category: :departure,
      modifier: 120,
      cost: 1_840
    },
    {
      name: '~19:00（1コマ）',
      category: :k_departure,
      modifier: 30,
      cost: 580
    },
    {
      name: '~19:30（2コマ）',
      category: :k_departure,
      modifier: 60,
      cost: 1_160
    },
    {
      name: '~20:00（3コマ）',
      category: :k_departure,
      modifier: 90,
      cost: 1_740
    },
    {
      name: '~20:30（4コマ）',
      category: :k_departure,
      modifier: 120,
      cost: 2_320
    }
  ].freeze

  DEFAULT_SPECIAL_OPTS = [
    {
      name: '中延長',
      category: :extension,
      cost: 1_380
    },
    {
      name: '中延長',
      category: :k_extension,
      cost: 1_740
    }
  ].freeze

  DEFAULT_MORN_OPTS = [
    {
      name: '昼食',
      category: :meal,
      cost: 770
    },
    {
      name: '9:30~（1コマ）',
      category: :arrival,
      modifier: -30,
      cost: 460
    },
    {
      name: '9:00~（2コマ）',
      category: :arrival,
      modifier: -60,
      cost: 920
    },
    {
      name: '8:30~（3コマ）',
      category: :arrival,
      modifier: -90,
      cost: 1_380
    },
    {
      name: '9:30~（1コマ）',
      category: :k_arrival,
      modifier: -30,
      cost: 580
    },
    {
      name: '9:00~（2コマ）',
      category: :k_arrival,
      modifier: -60,
      cost: 1_160
    },
    {
      name: '8:30~（3コマ）',
      category: :k_arrival,
      modifier: -90,
      cost: 1_740
    }
  ].freeze
end
