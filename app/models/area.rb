# frozen_string_literal: true

class Area < ApplicationRecord
  has_many :schools, inverse_of: :area, dependent: nil
  has_many :parents, -> { distinct }, through: :schools
  has_many :children, through: :schools
  has_many :invoices, through: :children
  has_many :events, -> { distinct }, through: :schools
  has_many :upcoming_events, lambda {
    where('end_date > ?', Time.zone.now)
      .order(start_date: :asc)
  },
           through: :schools,
           class_name: 'Event',
           dependent: nil
  has_many :time_slots, through: :events
  has_many :options, through: :time_slots
  has_many :option_registrations, through: :time_slots
  has_many :registrations, through: :time_slots
  has_many :managements, as: :manageable,
                         dependent: :destroy
  accepts_nested_attributes_for :managements,
                                allow_destroy: true,
                                reject_if: :all_blank
  has_many :managers, through: :managements

  validates :name, presence: true
end
