# frozen_string_literal: true

# Represents a user
# Access changes based on role
# Can be customer, school manager, area manager or admin
class User < ApplicationRecord
  # Set full name from submitted first and last names
  before_validation :set_name, :set_kana

  # Make sure Children are deleted when Parent is
  before_destroy :destroy_children

  # Allow use of separate fields to ensure consistent name formatting
  attr_accessor :first_name, :family_name, :kana_first, :kana_family

  # Staff associations
  has_many :managements, foreign_key: :manager_id,
                         inverse_of: :manager,
                         dependent: :destroy
  has_many :managed_schools, through: :managements,
                             source: :manageable,
                             source_type: 'School'
  has_many :school_setsumeikais, through: :managed_schools,
                                 source: :involved_setsumeikais
  has_many :school_children, through: :managed_schools,
                             source: :children
  has_many :school_events, -> { order(start_date: :desc) },
           through: :managed_schools,
           source: :events
  has_many :school_inquiries, through: :managed_schools,
                              source: :school_inquiries
  has_many :school_setsumeikai_inquiries, through: :managed_schools,
                                          source: :setsumeikai_inquiries
  has_many :managed_areas, through: :managements,
                           source: :manageable,
                           source_type: 'Area'
  has_many :area_schools, through: :managed_areas,
                          source: :schools
  has_many :area_survey_responses, through: :area_schools,
                                   source: :survey_responses
  has_many :area_setsumeikais, through: :area_schools,
                               source: :involved_setsumeikais
  has_many :area_inquiries, through: :area_schools,
                            source: :school_inquiries
  has_many :area_setsumeikai_inquiries, through: :area_schools,
                                        source: :setsumeikai_inquiries
  has_many :area_events, -> { order(start_date: :desc) },
           through: :area_schools,
           source: :events
  has_many :area_children, through: :area_schools,
                           source: :children

  # Customer associations
  has_many :children, dependent: nil,
                      foreign_key: :parent_id,
                      inverse_of: :parent
  accepts_nested_attributes_for :children,
                                allow_destroy: true,
                                reject_if: :all_blank
  validates_associated :children
  has_many :invoices, through: :children
  has_many :real_invoices, through: :children
  has_many :registrations, through: :children
  has_many :schools, -> { distinct }, through: :children
  has_many :areas, -> { distinct }, through: :schools
  has_many :time_slots, through: :children
  has_many :options, through: :children
  has_many :events, -> { order(start_date: :desc).distinct },
           through: :children
  has_many :mailer_subscriptions, dependent: :destroy

  # Track changes with PaperTrail
  has_paper_trail

  # Allow export/import with postgres-copy
  acts_as_copy_target

  # Validations
  validates :address, :katakana_name, :name, :phone, :postcode, :prefecture, presence: true
  validates :katakana_name, format: { with: /\A[ァ-ヶヶ　ー ]+\z/ }

  validates :email, confirmation: true

  validates :phone, format: { with: /\A[0-9 \-+x.)(]+\Z/ }

  validates :pin, length: { is: 4 }, allow_blank: true

  # Map role integer in db to a string
  enum :role, customer: 0,
              school_manager: 1,
              area_manager: 2,
              admin: 3,
              default: :customer

  # Scopes for each role
  scope :customers, -> { where(role: :customer) }
  scope :staff, -> { where(role: %i[admin area_manager school_manager]) }
  scope :area_managers, -> { where(role: :area_manager) }
  scope :school_managers, -> { where(role: :school_manager) }
  scope :admins, -> { where(role: :admin) }

  # Include default devise modules. Others available are:
  # :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :validatable, :lockable, :confirmable

  # Public methods
  def all_inquiries
    managed_school_ids = area_manager? ? area_schools.ids : managed_schools.ids

    Inquiry.where(
      'inquiries.school_id IN (?) OR inquiries.setsumeikai_id IN (?)',
      managed_school_ids,
      Setsumeikai.where(school_id: managed_school_ids).ids
    )
  end

  # Checks if User has children
  def children?
    return false if children.empty?

    true
  end

  def managed_school
    managed_schools.first
  end

  # Checks if User is a member of staff
  def staff?
    admin? || area_manager? || school_manager?
  end

  # Checks if user is subscribed to a mailer (opt-out strategy)
  def subscribed_to_mailer?(mailer)
    MailerSubscription.find_by(
      user: self,
      mailer: mailer,
      subscribed: false
    ).nil?
  end

  private

  def destroy_children
    children.destroy_all
  end

  def set_kana
    # Guard clause should never happen in prod because required field, but does
    # when directly modifying after creation in seeds file
    return if kana_first.nil? && kana_family.nil?

    self.katakana_name = [kana_family.strip, kana_first.strip].join(' ')
  end

  def set_name
    # Guard clause should never happen in prod because required field, but does
    # when directly modifying after creation in seeds file
    return if first_name.nil? && family_name.nil?

    self.name = [family_name.strip, first_name.strip].join(' ')
  end
end
