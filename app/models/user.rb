# frozen_string_literal: true

# Represents a user
# Access changes based on role
# Can be customer, school manager, area manager or admin
class User < ApplicationRecord
  belongs_to :school, optional: true
  has_one :area, through: :school

  has_many :managements, foreign_key: :manager_id,
                         inverse_of: :manager,
                         dependent: :destroy
  has_many :managed_schools, through: :managements,
                             source: :manageable,
                             source_type: 'School'
  has_many :managed_areas, through: :managements,
                           source: :manageable,
                           source_type: 'Area'
  has_many :children, dependent: :destroy,
                      foreign_key: :parent_id,
                      inverse_of: :parent
  has_many :registrations, through: :children
  has_many :time_slots, through: :registrations,
                        source: :registerable,
                        source_type: 'TimeSlot'
  has_many :events, through: :time_slots

  # Track changes with PaperTrail
  has_paper_trail

  # Validations
  validates :ja_first_name, :ja_family_name, :katakana_name, :en_name, :phone, presence: true

  validates :ja_first_name, :ja_family_name, format: { with: /[一-龠]+|[ぁ-ゔ]+|[ァ-ヴー]+|[々〆〤ヶ]+/u }
  validates :katakana_name, format: { with: /[ァ-ヴー]/u }
  validates :en_name, format: { with: /[A-Za-z '-]/ }

  validates :phone, format: { with: /\A[0-9 \-+x.)(]+\Z/, message: I18n.t('schools.validations.phone') }

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
