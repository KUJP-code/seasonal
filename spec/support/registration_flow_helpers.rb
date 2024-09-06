# frozen_string_literal: true

module RegistrationFlowHelpers
  def cost_text(expected_cost)
    localized_cost =
      ActionController::Base.helpers
                            .number_to_currency(expected_cost, locale: :ja)
    "合計（税込）: #{localized_cost}"
  end
end
