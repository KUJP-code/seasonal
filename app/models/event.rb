# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :school
  delegate :area, to: :school

  has_many :time_slots, dependent: :destroy
  has_many :registrations, through: :time_slots
  has_many :children, through: :registrations

  validates :name, :description, :start_date, :end_date, presence: true

  validates :start_date, comparison: { greater_than_or_equal_to: Time.zone.today, less_than_or_equal_to: :end_date }
  validates :end_date, comparison: { greater_than_or_equal_to: Time.zone.today }
  validates_comparison_of :end_date, greater_than_or_equal_to: :start_date

  # Set scopes for event status
  scope :past_events, -> { where('end_date < ?', Time.zone.today) }
  scope :current_events, -> { where('start_date <= ? and end_date >= ?', Time.zone.today, Time.zone.today) }
  scope :future_events, -> { where('start_date > ?', Time.zone.today) }

  # TODO: Do this with ActiveRecord, not select
  def diff_school_attendees
    children.reject { |child| child.school == school }
  end
end
