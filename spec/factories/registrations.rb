# frozen_string_literal: true

FactoryBot.define do
  factory :registration do
    child { create(:child) }
    registerable { create(:time_slot) }
    cost { registerable.cost }

    # TODO: fill this out once options exist, probs also make time slot not default
    # trait :option do
    #   registerable {  }
    # end
  end
end
