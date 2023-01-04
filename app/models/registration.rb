# frozen_string_literal: true

class Registration < ApplicationRecord
  belongs_to :child
  belongs_to :registerable, polymorphic: true
  delegate :event, to: :registerable
  delegate :school, to: :registerable
  delegate :parent, to: :child
  delegate :area, to: :event
end
