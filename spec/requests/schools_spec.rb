require 'rails_helper'

RSpec.describe 'Schools', type: :request do
  describe 'GET /schools' do
    context 'when accessing schools with JSON format' do
      it 'returns a successful response with schools JSON data' do
        get '/schools', params: { format: :json }

        puts "Redirected to: #{response.location}" if response.redirect?

        expect(response).to have_http_status(:success)
      end
    end
  end
end
