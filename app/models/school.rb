# frozen_string_literal: true

class School < ApplicationRecord
  belongs_to :manager, class_name: 'User'
  belongs_to :area

  has_many :users, dependent: :restrict_with_exception
  has_many :children, dependent: nil
  has_many :events, dependent: :destroy
  has_many :time_slots, through: :events

  validates :name, :address, :phone, presence: true
  validates :phone, format: { with: /\A[0-9 \-+x.)(]+\Z/, message: I18n.t('schools.validations.phone') }
end
