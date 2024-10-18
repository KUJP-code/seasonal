require 'rails_helper'

RSpec.describe 'Schools', type: :request do
  describe 'GET /schools' do
    context 'when accessing schools with JSON format' do
      before do
        # Create some test schools
        FactoryBot.create(:school, name: 'School A')
        FactoryBot.create(:school, name: 'School B')
      end

      it 'returns a successful response with schools JSON data' do
        get '/schools', params: { format: :json }

        expect(response).to have_http_status(:success)
        schools = JSON.parse(response.body)
        expect(schools).not_to be_empty
        expect(schools.first).to have_key('id')
        expect(schools.first).to have_key('name')
      end
    end
  end
end
