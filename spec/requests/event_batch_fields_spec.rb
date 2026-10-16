# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Editing shared Event Fields' do
  let(:event) { create(:event, name: 'Winter School', description: '<div>Original</div>') }

  before { sign_in create(:admin) }

  it 'offers the matching-name option and a direct link from the bulk page' do
    create(:event, name: event.name)

    get edit_event_path(id: event.id)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Apply Event Fields to all 2 events')

    get bulk_events_path(name: event.name)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Edit Event Fields for all 2 events')
  end

  it 'copies all Event Fields to forty matching events and retains school-specific records' do
    source = event
    # Exercise the full forty-school workflow.
    # rubocop:disable FactoryBot/ExcessiveCreateList
    matches = create_list(:event, 39, name: source.name, member_prices: source.member_prices,
                                      non_member_prices: source.non_member_prices)
    # rubocop:enable FactoryBot/ExcessiveCreateList
    original_schools = [source, *matches].to_h { |record| [record.id, record.school_id] }
    source_option = create(:event_option, optionable: source, name: 'School option')
    other_option = create(:event_option, optionable: matches.first, name: 'Other school option')
    original_slot = create(:time_slot, :afternoon, event: matches.first)
    new_prices = create(:member_prices, name: 'New prices')
    image = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new('image'), filename: 'event.png', content_type: 'image/png', identify: false
    )
    avif = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new('avif'), filename: 'event.avif', content_type: 'image/avif', identify: false
    )
    unrelated = create(:event, name: 'Other Event', description: 'Keep this')
    fields = {
      name: 'Winter Adventures', description: '<div><strong>Shared description</strong></div>',
      start_date: '2026-12-20', end_date: '2026-12-28', goal: 250_000,
      early_bird_date: '2026-12-01', early_bird_discount: 0, released: false,
      member_prices_id: new_prices.id, non_member_prices_id: new_prices.id,
      image_id: image.id, avif_id: avif.id, school_id: matches.first.school_id,
      options_attributes: { '0' => { id: source_option.id, name: 'Updated school option' } }
    }

    patch event_path(id: source.id), params: { apply_to_matching_events: '1', event: fields }

    expect(response).to redirect_to(edit_event_path(id: source.id, locale: :en))
    expect(flash[:notice]).to include('40 events')
    [source, *matches].each do |record|
      record.reload
      expect(record).to have_attributes(
        name: 'Winter Adventures', start_date: Date.new(2026, 12, 20),
        end_date: Date.new(2026, 12, 28), goal: 250_000,
        early_bird_date: Date.new(2026, 12, 1), early_bird_discount: 0, released: false,
        member_prices_id: new_prices.id, non_member_prices_id: new_prices.id,
        school_id: original_schools.fetch(record.id)
      )
      expect(record.description.body.to_html).to include('<strong>Shared description</strong>')
      expect(record.image.blob).to eq(image)
      expect(record.avif.blob).to eq(avif)
    end
    expect(source_option.reload.name).to eq('Updated school option')
    expect(other_option.reload.name).to eq('Other school option')
    expect(matches.first.time_slots).to contain_exactly(original_slot)
    expect(unrelated.reload.description.to_plain_text).to eq('Keep this')
    expect(unrelated.name).to eq('Other Event')
  end

  it 'keeps ordinary edits confined to the selected school' do
    other = create(:event, name: event.name, description: 'Other description')

    patch event_path(id: event.id), params: {
      event: { school_id: event.school_id, description: '<div>Local edit</div>' }
    }

    expect(response).to have_http_status(:redirect)
    expect(event.reload.description.to_plain_text).to eq('Local edit')
    expect(other.reload.description.to_plain_text).to eq('Other description')
  end

  it 'matches the saved name when a batch edit also changes the name' do
    matching = create(:event, name: event.name)
    other_group = create(:event, name: 'Renamed', description: 'Other group')

    patch event_path(id: event.id), params: {
      apply_to_matching_events: '1', event: { name: 'Renamed',
                                              description: '<div>Shared edit</div>' }
    }

    expect(response).to have_http_status(:redirect)
    expect(matching.reload.name).to eq('Renamed')
    expect(matching.description.to_plain_text).to eq('Shared edit')
    expect(other_group.reload.description.to_plain_text).to eq('Other group')
  end

  it 'rolls back all event and description changes when one matching event is invalid' do
    matching = create(:event, name: event.name, description: 'Other original')
    # Simulate invalid historical data to verify transaction rollback.
    matching.update_column(:end_date, matching.start_date - 1.day) # rubocop:disable Rails/SkipsModelValidations

    patch event_path(id: event.id), params: {
      apply_to_matching_events: '1', event: { name: 'Renamed',
                                              description: '<div>Shared edit</div>' }
    }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include(matching.school.name)
    expect(event.reload.name).to eq('Winter School')
    expect(event.description.to_plain_text).to eq('Original')
    expect(matching.reload.name).to eq('Winter School')
    expect(matching.description.to_plain_text).to eq('Other original')
  end

  it 'rejects invalid source fields without updating the other schools' do
    matching = create(:event, name: event.name)

    patch event_path(id: event.id), params: {
      apply_to_matching_events: '1', event: { name: '', description: '<div>Shared edit</div>' }
    }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(event.reload.description.to_plain_text).to eq('Original')
    expect(matching.reload.name).to eq('Winter School')
  end

  it 'does not permit non-admins to batch edit events' do
    sign_out :user
    sign_in create(:customer)

    patch event_path(id: event.id), params: {
      apply_to_matching_events: '1', event: { name: 'Unauthorized change' }
    }

    expect(response).to redirect_to(root_path(locale: I18n.locale))
    expect(event.reload.name).to eq('Winter School')
  end
end
