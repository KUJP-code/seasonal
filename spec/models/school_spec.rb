require 'rails_helper'

RSpec.describe 'Schools', type: :request do
  describe 'GET /schools' do
    context 'when accessing the schools endpoint from a fetch request' do
      it 'returns a successful response with schools JSON data' do
        area = Area.create
        # Create some dummy school data for testing
        School.create!(name: 'School 1', address: 'Address 1', phone: '123456789', area:)
        School.create!(name: 'School 2', address: 'Address 2', phone: '987654321', area:)

        # Send a GET request simulating a fetch with Accept header for JSON
        get '/schools', headers: { 'ACCEPT' => 'application/json' }

        # Expect the response to be successful
        expect(response).to have_http_status(:success)

        # Parse the JSON response
        schools = JSON.parse(response.body)

        # Ensure the JSON contains the expected school data
        expect(schools).not_to be_empty
        expect(schools.first).to have_key('id')
        expect(schools.first).to have_key('name')
        expect(schools.first['name']).to eq('School 1')
      end
    end
  end
end
