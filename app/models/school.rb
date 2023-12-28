# frozen_string_literal: true

class School < ApplicationRecord
  # Allow API details to be set
  store_accessor :details, :bus_areas
  store_accessor :details, :hiragana
  store_accessor :details, :nearby_schools
  store_accessor :details, :nearby_stations

  before_validation :set_details

  belongs_to :area
  has_one_attached :image
  has_many :managements, as: :manageable,
                         dependent: :destroy
  accepts_nested_attributes_for :managements,
                                allow_destroy: true,
                                reject_if: :all_blank
  has_many :managers, through: :managements
  has_many :children, dependent: nil
  has_many :invoices, through: :children
  has_many :coupons, through: :invoices
  has_many :parents, -> { distinct }, through: :children,
                                      class_name: 'User',
                                      foreign_key: :parent_id
  has_many :survey_responses, through: :children
  has_many :events, -> { order(start_date: :asc) }, dependent: :destroy,
                                                    inverse_of: :school
  has_many :upcoming_events,
           lambda {
             where('end_date > ?', Time.zone.now)
               .order(start_date: :asc)
           },
           class_name: 'Event',
           dependent: nil,
           inverse_of: :school
  has_many :time_slots, through: :events
  has_many :options, through: :time_slots
  has_many :option_registrations, through: :time_slots
  has_many :registrations, through: :time_slots
  has_many :setsumeikais, dependent: nil
  has_many :setsumeikai_inquiries, through: :setsumeikais,
                                   source: :inquiries,
                                   class_name: 'Inquiry'
  has_many :inquiries, dependent: nil
  has_many :setsumeikai_involvements, dependent: :destroy
  has_many :involved_setsumeikais, through: :setsumeikai_involvements,
                                   source: :setsumeikai,
                                   class_name: 'Setsumeikai'
  has_many :calendar_setsumeikais,
           -> { where('start > ? AND release_date < ?', Time.zone.now, Time.zone.today + 1.day) },
           through: :setsumeikai_involvements,
           source: :setsumeikai,
           class_name: 'Setsumeikai'

  # Scopes
  scope :real, -> { where.not(name: %w[オンラインコース Test]) }

  # Validations
  validates :name, presence: true

  def as_json(_options = {})
    {
      id: id.to_s,
      name: name,
      address: address,
      phone: phone,
      image: Rails.env.production? ? image.url : '',
      busAreas: details['bus_areas'] || [''],
      hiragana: details['hiragana'] || [''],
      nearbySchools: details['nearby_schools'] || [''],
      nearbyStations: details['nearby_stations'] || [''],
      setsumeikais: calendar_setsumeikais
    }
  end

  def hat_kids
    children.where(received_hat: false)
            .joins(:adjustments)
            .where(
              adjustments: {
                reason: '帽子代(野外アクティビティに参加される方でKids UP帽子をお持ちでない方のみ)'
              }
            )
  end

  def image_id
    return nil if image.blob.nil?

    image.blob.id
  end

  def image_id=(image_id)
    return if image_id.nil?

    self.image = ActiveStorage::Blob.find(image_id)
  end

  # I want to keep the possibility of multiple managers per school open,
  # since mine has 2. But school.managers.first is annoying/ugly
  def manager
    managers.first
  end

  def next_event
    upcoming_events.first
  end

  def to_gas_api
    { school_name: name, email: email || '' }
  end

  private

  def set_details
    # This saves us creating a bunch of stuff for testing
    return if details.nil?

    self.details = {
      bus_areas: bus_areas.split(/, |,/),
      hiragana: hiragana.split(/, |,/),
      nearby_schools: nearby_schools.split(/, |,/),
      nearby_stations: nearby_stations.split(/, |,/)
    }
  end
end
