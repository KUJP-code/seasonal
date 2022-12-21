# frozen_string_literal: true

# Manages AR data for User class
class User < ApplicationRecord
  # belongs_to :school
  # has_one :managed_school, class_name: 'School',
  #                          foreign_key: :manager_id,
  #                          inverse_of: :manager,
  #                          dependent: :restrict_with_exception
  # has_one :area, through: :school
  has_one :managed_area, class_name: 'Area',
                         foreign_key: :manager_id,
                         inverse_of: :manager,
                         dependent: :restrict_with_exception

  # Map role integer in db to a string w/methods
  enum :role, customer: 0, school_manager: 1, area_manager: 2, admin: 3, default: :customer

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
