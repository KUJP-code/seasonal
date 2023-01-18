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
  has_many :area_schools, through: :managed_areas,
                          source: :schools
  has_many :children, dependent: :destroy,
                      foreign_key: :parent_id,
                      inverse_of: :parent
  accepts_nested_attributes_for :children
  has_many :registrations, through: :children
  has_many :time_slots, through: :registrations,
                        source: :registerable,
                        source_type: 'TimeSlot'
  has_many :registered_options, through: :registrations,
                                source: :registerable,
                                source_type: 'Option'
  has_many :events, -> { distinct }, through: :time_slots

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

  # Scopes for each role
  scope :customers, -> { where(role: :customer) }
  scope :area_managers, -> { where(role: :area_manager) }
  scope :school_managers, -> { where(role: :school_manager) }
  scope :admins, -> { where(role: :admin) }

  # Scopes for User#index to display to each role
  scope :admin_index, -> { order(updated_at: :desc).includes(:children, :school) }

  scope :sm_index, lambda { |sm|
    where(school: sm.managed_schools)
      .order(updated_at: :desc)
      .limit(12)
      .includes(:children, :school)
  }
  scope :am_index, lambda { |am|
    where(school: School.where(area: am.managed_areas))
      .order(updated_at: :desc)
      .limit(12)
      .includes(:children, :school)
  }

  # Scope for User#show TODO: Optimise properly once the view is finalised
  scope :user_show, lambda { |param_id|
    where(id: param_id).includes(:children,
                                 :events,
                                 :registrations,
                                 :time_slots,
                                 :registered_options,
                                 :managed_schools,
                                 :managed_areas,
                                 :school)
                       .first
  }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Public methods
  # Checks if User is a member of staff
  def staff?
    admin? || area_manager? || school_manager?
  end

  # Checks if User has children
  def children?
    return false if children.empty?

    true
  end

  # Concatenates the two Japanese names for easier use
  def name
    "#{ja_family_name} #{ja_first_name}"
  end
end
