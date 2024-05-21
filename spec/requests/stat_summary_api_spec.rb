# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Statistics summary API for Google Sheet' do
  let!(:member_prices) { create(:member_prices, course1: '10') }
  let!(:non_member_prices) { create(:non_member_prices, course1: '20') }
  let!(:event) do
    create(:event, name: 'Test Event', goal: 10, member_prices:, non_member_prices:)
  end
  let!(:time_slot) { create(:time_slot, event:) }

  before do
    create_list(:child, 2, category: :internal)
    create_list(:child, 2, category: :reservation)
    create_list(:child, 2, category: :external)
    Child.find_each do |c|
      invoice = c.invoices.create!(event_id: event.id)
      c.registrations.create!(invoice_id: invoice.id, registerable: time_slot)
      invoice.reload.calc_cost && invoice.save
    end
  end

  it 'returns JSON in the expected format' do
    ENV['SHEETS_API_ACCESS_KEY'] = 'test'
    expected_response = {
      'Test Event' => [
        {
          'school_id' => event.school_id,
          'member_count' => 4,
          'member_revenue' => 40,
          'external_count' => 2,
          'external_revenue' => 2240,
          'total_revenue' => event.invoices.sum(:total_cost),
          'goal' => 10
        }
      ]
    }.to_json
    get '/gas_summary', params: { accessKey: 'test', events: ['Test Event'] }
    expect(response).to have_http_status(:ok)
    expect(response.content_type).to eq('application/json; charset=utf-8')
    expect(response.body).to eq(expected_response)
  end
end
