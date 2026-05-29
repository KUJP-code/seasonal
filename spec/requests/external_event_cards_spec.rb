# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'External event cards' do
  let(:school) { create(:school) }

  before { sign_in create(:admin) }

  it 'allows admins to view the management screens' do
    create(:external_event_card, title: 'Science 2026', schools: [school])

    get external_event_cards_path(locale: :ja)
    expect(response).to have_http_status(:success)
    expect(response.body).to include('Science 2026')

    get new_external_event_card_path(locale: :ja)
    expect(response).to have_http_status(:success)
    expect(response.body).to include('Active')
  end

  it 'allows admins to create inactive cards with school-specific variants' do
    expect do
      post external_event_cards_path(locale: :ja),
           params: {
             external_event_card: {
               title: 'Science 2026',
               url: 'https://my.ptsc.jp/kids-up/entry?i=Science2026',
               note: 'External registration',
               starts_on: '2026-05-10',
               ends_on: '2026-07-05',
               active: '0',
               variants_attributes: {
                 '0' => {
                   event_on: '2026-07-04',
                   school_ids: [school.id]
                 }
               }
             }
           }
    end.to change(ExternalEventCard, :count).by(1)

    card = ExternalEventCard.last
    expect(card).not_to be_active
    expect(card.variants.first.schools).to contain_exactly(school)
    expect(response).to redirect_to(external_event_cards_path(locale: :en))
  end
end
