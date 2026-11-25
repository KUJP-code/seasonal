# frozen_string_literal: true

# Represents adjustments to the price of registrations
class Adjustment < ApplicationRecord
  EARLY_BIRD = '早割'
  FIRST_TIME = '初回登録料(初めてシーズナルスクールに参加する非会員の方)'
  HAT = '帽子代(野外アクティビティに参加される方でKids UP帽子をお持ちでない方のみ)'
  REPEATER = '非会員リピーター割引(以前シーズナルスクールに参加された非会員の方)'
  # Added by the pricing code itself; any other reason was entered by staff.
  AUTOMATIC_REASONS = [EARLY_BIRD, FIRST_TIME, HAT, REPEATER].freeze

  belongs_to :invoice

  # Validations
  validates :change, :reason, presence: true
  validates :change, numericality: { only_integer: true }

  def manual?
    !change.to_i.zero? && AUTOMATIC_REASONS.exclude?(reason)
  end

  def reason_cost
    "#{reason}: #{change.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円"
  end
end
