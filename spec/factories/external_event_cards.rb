# frozen_string_literal: true

FactoryBot.define do
  factory :external_event_card do
    title { 'Mega Game 2026' }
    url { 'https://my.ptsc.jp/kids-up/entry?i=Mega2026' }
    note { 'External registration' }
    starts_on { Date.new(2026, 5, 1) }
    ends_on { Date.new(2026, 5, 31) }
    active { true }

    transient do
      schools { [association(:school)] }
      event_on { Date.new(2026, 5, 23) }
    end

    after(:build) do |card, evaluator|
      card.variants << build(
        :external_event_card_variant,
        external_event_card: card,
        event_on: evaluator.event_on,
        schools: evaluator.schools
      )
    end
  end

  factory :external_event_card_variant do
    external_event_card
    event_on { Date.new(2026, 5, 23) }
    schools { [association(:school)] }
  end
end
