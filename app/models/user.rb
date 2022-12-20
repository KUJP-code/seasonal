# frozen_string_literal: true

# Manages AR data for User class
class User < ApplicationRecord
  # Map role integer in db to a string w/methods
  enum :role, customer: 0, school_manager: 1, area_manager: 2, admin: 3, default: :customer

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
