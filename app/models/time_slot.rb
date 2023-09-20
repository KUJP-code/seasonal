# frozen_string_literal: true

# Represents an event time slot
# Must have an event
class TimeSlot < ApplicationRecord
  after_create :create_default_opts, :create_aft_slot

  attr_accessor :apply_all

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
                                                 reject_if: :all_blank

  has_one_attached :image

  # Validations
  validates :name, :start_time, :end_time, presence: true

  validates_comparison_of :end_time, greater_than: :start_time

  # Map category integer in db to a string
  enum :category, seasonal: 0,
                  special: 1,
                  party: 2,
                  outdoor: 3

  # Scopes
  # For time slot status
  scope :past_slots, -> { where('end_time < ?', Time.zone.now).order(start_time: :desc) }
  scope :todays_slots, lambda {
    where('start_time > ? and end_time < ?',
          Time.zone.today.midnight,
          Time.zone.tomorrow.midnight).order(start_time: :asc)
  }
  scope :future_slots, -> { where('start_time >= ?', Time.zone.now).order(start_time: :asc) }

  # For type of time slot
  scope :morning, -> { where(morning: true).order(start_time: :asc) }
  scope :afternoon, -> { where(morning: false).order(start_time: :asc) }

  # Public methods
  # Consolidates manual closing and automatic closing into one check
  def closed?
    return true if closed

    close_date = CLOSE_DATES[name]
    return false if close_date.nil?

    Time.zone.now > close_date
  end

  # These convert the start/end datetimes into something more useful for display
  def date
    start_time.strftime('%m月%d日') + " #{ja_day}"
  end

  def day
    start_time.strftime('%A')
  end

  def f_end_time
    end_time.strftime('%I:%M%p')
  end

  def f_start_time
    start_time.strftime('%I:%M%p')
  end

  def image_id
    return nil if image.blob.nil?

    image.blob.id
  end

  def image_id=(image_id)
    return if image_id.nil?

    self.image = ActiveStorage::Blob.find(image_id)
  end

  def ja_day
    en_day = start_time.strftime('%A')

    "(#{DAYS[en_day]})"
  end

  def times
    "#{f_start_time} - #{f_end_time}"
  end

  private

  def create_aft_slot
    return if !morning || special?

    create_afternoon_slot(
      name: name,
      start_time: start_time + 5.hours,
      end_time: end_time + 5.hours,
      category: category,
      morning: false,
      event_id: event_id,
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

  CLOSE_DATES = {
    'カラフルテープアート' => 'Wed, 19 Jul 2023 14:00 JST +9:00',
    'ピクチャーキーホルダー' => 'Thu, 20 Jul 2023 14:00 JST +9:00',
    '冒険者のクエスト！' => 'Fri, 21 Jul 2023 14:00 JST +9:00',
    'ウォーターベースボール(7月25日)' => 'Mon, 24 Jul 2023 14:00 JST +9:00',
    '忍者になろう！' => 'Tue, 25 Jul 2023 14:00 JST +9:00',
    'フルーツスムージー★' => 'Wed, 26 Jul 2023 14:00 JST +9:00',
    '世界のゲームを体験しよう' => 'Thu, 27 Jul 2023 14:00 JST +9:00',
    '水鉄砲合＆スイカ割り！' => 'Fri, 28 Jul 2023 14:00 JST +9:00',
    '巨大なお城のクラフト＆アイスクリーム屋さん' => 'Fri, 28 Jul 2023 14:00 JST +9:00',
    'サボテンクラフト' => 'Fri, 28 Jul 2023 14:00 JST +9:00',
    'ハワイアンかき氷' => 'Mon, 31 Jul 2023 14:00 JST +9:00',
    '水鉄砲合戦!!(8月2日)' => 'Tue, 1 Aug 2023 14:00 JST +9:00',
    'BBQ風焼きそば' => 'Wed, 2 Aug 2023 14:00 JST +9:00',
    'ペーパーランタン' => 'Wed, 2 Aug 2023 14:00 JST +9:00',
    '海のスライム' => 'Thu, 3 Aug 2023 14:00 JST +9:00',
    'Kids Up★ゲームセンター' => 'Fri, 4 Aug 2023 14:00 JST +9:00',
    '水鉄砲合戦!!(8月8日)' => 'Mon, 7 Aug 2023 14:00 JST +9:00',
    'アメリカン★ホットドッグ' => 'Tue, 8 Aug 2023 14:00 JST +9:00',
    'オレオシェイク' => 'Tue, 8 Aug 2023 14:00 JST +9:00',
    'オリジナルバッグ作り' => 'Wed, 9 Aug 2023 14:00 JST +9:00',
    'デザートスライム' => 'Wed, 16 Aug 2023 14:00 JST +9:00',
    'ウォーターゲーム対決！' => 'Thu, 17 Aug 2023 14:00 JST +9:00',
    '水鉄砲合戦!!(8月21日)' => 'Fri, 18 Aug 2023 14:00 JST +9:00',
    '暗闇で光るスライム' => 'Tue, 22 Aug 2023 14:00 JST +9:00',
    'DIY水族館' => 'Wed, 23 Aug 2023 14:00 JST +9:00',
    '貝殻ペンダント' => 'Thu, 24 Aug 2023 14:00 JST +9:00',
    'ウォーターベースボール(8月28日)' => 'Fri, 25 Aug 2023 14:00 JST +9:00',
    'バンダナの絞り染め' => 'Fri, 25 Aug 2023 14:00 JST +9:00',
    '夏祭り' => 'Fri, 25 Aug 2023 14:00 JST +9:00',
    'レインボーキーホルダー' => 'Mon, 28 Aug 2023 14:00 JST +9:00',
    'ビーチジオラマ' => 'Tue, 29 Aug 2023 14:00 JST +9:00',
    'フレンチクレープ' => 'Wed, 30 Aug 2023 14:00 JST +9:00',
    'アイスクリーム屋さん' => 'Wed, 30 Aug 2023 14:00 JST +9:00'
  }.freeze

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
      cost: 660
    },
    {
      name: 'なし',
      category: :departure,
      modifier: 0,
      cost: 0
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
      name: 'なし',
      category: :k_departure,
      modifier: 0,
      cost: 0
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
      cost: 660
    },
    {
      name: 'なし',
      category: :arrival,
      modifier: 0,
      cost: 0
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
      name: 'なし',
      category: :k_arrival,
      modifier: 0,
      cost: 0
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
