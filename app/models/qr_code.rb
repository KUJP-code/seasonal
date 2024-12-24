# frozen_string_literal:true

class QrCode < ApplicationRecord
  has_many :qr_code_usages, dependent: :destroy
  validates :name, presence: true, uniqueness: true
end
