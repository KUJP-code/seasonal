# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'External event card' do
  include ActiveSupport::Testing::TimeHelpers

  let(:parent) { create(:customer) }
  let(:school) { create(:school, name: '東陽町') }
  let(:other_school) { create(:school, name: '長原') }
  let(:child) { create(:child, parent:, school:) }

  before do
    travel_to Date.new(2026, 5, 23)
    sign_in parent
  end

  after do
    sign_out parent
  end

  it 'shows an active card for the child school' do
    create(
      :external_event_card,
      title: 'Mega Game 2026',
      url: 'https://my.ptsc.jp/kids-up/entry?i=Mega2026',
      note: 'External registration',
      schools: [school],
      event_on: Date.new(2026, 5, 23)
    )
    create(
      :external_event_card,
      title: 'Other School Event',
      schools: [other_school],
      event_on: Date.new(2026, 7, 5)
    )

    visit child_path(id: child.id)

    expect(page).to have_link('Mega Game 2026', href: 'https://my.ptsc.jp/kids-up/entry?i=Mega2026')
    expect(page).to have_content('5月23日')
    expect(page).to have_content('External registration')
    expect(page).to have_no_content('Other School Event')
  end
end
