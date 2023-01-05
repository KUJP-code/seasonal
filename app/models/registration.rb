# frozen_string_literal: true

# Represents an individual child's registration for either time slot or option
# Must have a child, and the registered time slot/option
class Registration < ApplicationRecord
  belongs_to :child
  belongs_to :registerable, polymorphic: true
  delegate :event, to: :registerable
  delegate :area, to: :event
  delegate :school, to: :registerable
  delegate :parent, to: :child

  # Set scopes for registerable type
  scope :slot_registrations, -> { where(registerable_type: 'TimeSlot') }
  scope :option_registrations, -> { where(registerable_type: 'Option') }
end
