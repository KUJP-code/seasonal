# frozen_string_literal: true

class ExternalEventCardVariantSchool < ApplicationRecord
  belongs_to :external_event_card_variant,
             inverse_of: :external_event_card_variant_schools
  belongs_to :school
end
