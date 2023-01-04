# frozen_string_literal: true

# Represents a user
# Access changes based on role
# Can be customer, school manager, area manager or admin
class User < ApplicationRecord
  belongs_to :school, optional: true
  # TODO: Maybe I should just use has_many for this cos of the bug??
  has_one :managed_school, class_name: 'School',
                           foreign_key: :manager_id,
                           inverse_of: :manager,
                           dependent: :restrict_with_exception
  has_one :area, through: :school
  # TODO: Maybe I should just use has_many for this cos of the bug??
  has_one :managed_area, class_name: 'Area',
                         foreign_key: :manager_id,
                         inverse_of: :manager,
                         dependent: :restrict_with_exception

  has_many :children, dependent: :destroy,
                      foreign_key: :parent_id,
                      inverse_of: :parent
  has_many :registrations, through: :children
  has_many :time_slots, through: :registrations,
                        source: :registerable,
                        source_type: 'TimeSlot'
  has_many :events, through: :time_slots

  # Map role integer in db to a string
  enum :role, customer: 0,
              school_manager: 1,
              area_manager: 2,
              admin: 3,
              default: :customer

  # Create scopes for each role
  scope :customers, -> { where(role: :customer) }
  scope :area_managers, -> { where(role: :area_manager) }
  scope :school_managers, -> { where(role: :school_manager) }
  scope :admins, -> { where(role: :admin) }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
