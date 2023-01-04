# frozen_string_literal: true

# Represents a single school
# Must have a school manager
class School < ApplicationRecord
  belongs_to :area

  has_many :managements, as: :manageable,
                         dependent: :destroy
  has_many :managers, through: :managements
  has_many :users, dependent: :restrict_with_exception
  has_many :children, dependent: nil
  has_many :events, dependent: :destroy
  has_many :time_slots, through: :events
  has_many :registrations, through: :time_slots

  validates :name, :address, :phone, presence: true
  validates :phone, format: { with: /\A[0-9 \-+x.)(]+\Z/, message: I18n.t('schools.validations.phone') }
  validate :managers, :school_manager?

  private

  def school_manager?
    return false unless managers || managers.all(&:school_manager?)

    true
  end
end
