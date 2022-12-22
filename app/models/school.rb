# frozen_string_literal: true

class School < ApplicationRecord
  belongs_to :manager, class_name: 'User'
  belongs_to :area

  has_many :users, dependent: :restrict_with_exception

  validates :phone, format: { with: /\A[0-9 \-+x.)(]+\Z/ }
end
