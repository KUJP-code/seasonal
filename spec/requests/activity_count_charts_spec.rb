# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Activity count statistics' do
  let(:event) { create(:event, name: 'Summer School') }
  let!(:slots) { create_list(:time_slot, 6, event:) }
  let(:five_activity_child) { create(:child, name: 'Five Activities') }
  let(:four_activity_child) { create(:child, name: 'Four Activities') }

  before do
    sign_in create(:admin)
    register_for_slots(five_activity_child, slots.first(5))
    register_for_slots(four_activity_child, slots.first(4))
  end

  it 'shows an aggregate table instead of child names' do
    get charts_path, params: {
      category: 'activity_counts', event: event.name, activity_count: 5
    }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Children with exactly 5 activities')
    expect(response.body).to include('Activity-count table')
    expect(response.body).not_to include('Five Activities', 'Four Activities')
  end

  it 'limits results to the selected school' do
    other_event = create(:event, name: event.name)
    other_slots = create_list(:time_slot, 5, event: other_event)
    other_child = create(:child, name: 'Other School Five')
    register_for_slots(other_child, other_slots, other_event)

    get chart_path(id: event.school_id), params: {
      category: 'activity_counts', event: event.name, activity_count: 5
    }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Activity-count table')
    expect(response.body).not_to include('Other School Five')
  end

  it 'shows exact and at-least totals together' do
    get charts_path, params: {
      category: 'activity_counts', event: event.name,
      activity_count: 4
    }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Children with exactly 4 activities')
    expect(response.body).to include('Children with 4 or more activities')
  end

  it 'downloads exact-match results as CSV' do
    get charts_path(format: :csv), params: {
      category: 'activity_counts', event: event.name, activity_count: 5
    }

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('text/csv')
    csv = CSV.parse(response.body, headers: true)
    expect(csv.headers).to eq(
      ['Activity Count', 'Children Exactly', 'Children At Least', 'Event', 'School']
    )
    five_row = csv.find { |row| row['Activity Count'] == '5' }
    expect(five_row.to_h).to include(
      'Children Exactly' => '1', 'Children At Least' => '1'
    )
  end

  private

  def register_for_slots(child, selected_slots, selected_event = event)
    invoice = create(:invoice, child:, event: selected_event)
    selected_slots.each { |slot| create(:registration, child:, invoice:, registerable: slot) }
  end
end
