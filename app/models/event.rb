# frozen_string_literal: true

# Represents an event at a single school, with one or many time slots
# Must have a school
class Event < ApplicationRecord
  belongs_to :school
  delegate :area, to: :school
  belongs_to :member_prices, class_name: 'PriceList',
                             optional: true
  belongs_to :non_member_prices, class_name: 'PriceList',
                                 optional: true

  has_many :time_slots, dependent: :destroy
  accepts_nested_attributes_for :time_slots, allow_destroy: true,
                                             reject_if: :all_blank
  has_many :options, as: :optionable,
                     dependent: :destroy
  has_many :event_option_regs, through: :options,
                               source: :registrations
  accepts_nested_attributes_for :options, allow_destroy: true,
                                          reject_if: :all_blank
  has_many :slot_options, through: :time_slots,
                          source: :options
  has_many :option_registrations, through: :time_slots
  has_many :registrations, through: :time_slots
  has_many :invoices, -> { real },
                      dependent: :destroy,
                      inverse_of: :event
  has_many :children, -> { distinct }, through: :invoices

  has_one_attached :image
  has_one_attached :banner

  validates :name, :start_date, :end_date, presence: true

  validates_comparison_of :end_date, greater_than_or_equal_to: :start_date

  # Scopes
  scope :real, -> { where.not(school_id: [1, 2]).includes(:school) }
  scope :upcoming, -> { where('end_date > ?', Time.zone.now) }

  # Public Methods
  # List children attending from other schools
  def diff_school_children
    children.where.not(school: school).distinct
  end

  def f_start_date
    start_date.strftime('%Y年%m月%d日')
  end

  def image_id
    return nil if image.blob.nil?

    image.blob.id
  end

  def image_id=(image_id)
    return if image_id.nil?

    self.image = ActiveStorage::Blob.find(image_id)
  end

  # Returns num of registrations for the フォトサービス event option
  # free regs from siblings being registered not included
  def photo_regs
    photo_opt = options.find_by(name: 'フォトサービス')
    return 0 if photo_opt.nil?

    photo_id = photo_opt.id
    Registration.all.where(registerable_type: 'Option', registerable_id: photo_id).size
  end
end
