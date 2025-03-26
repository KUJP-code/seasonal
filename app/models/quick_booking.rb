# frozen_string_literal: true

class QuickBooking < ApplicationRecord
  belongs_to :school
  validates :first_name, :last_name, :email, :phone, presence: true
end
