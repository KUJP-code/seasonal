require 'rails_helper'

RSpec.describe 'Schools', type: :request do
  describe 'GET /schools' do
    context 'when accessing schools with JSON format' do
      it 'does not redirect and returns JSON data' do
        # Simulate a fetch request without authentication
        get '/schools', params: { format: :json }

        # If a redirect occurs, print the redirection location
        puts "Redirected to: #{response.location}" if response.redirect?

        # Expect no redirect and a success status
        expect(response).not_to be_redirect
        expect(response).to have_http_status(:success)

        # Parse the JSON response to ensure it includes expected data
        schools = JSON.parse(response.body)
        expect(schools).to be_an(Array)
        expect(schools.first).to have_key('id')
        expect(schools.first).to have_key('name')
      end

      it 'redirects if accessed via HTML format' do
        # Simulate a fetch request with HTML format
        get '/schools', params: { format: :html }

        # Check for redirection and print where it redirects
        puts "Redirected to: #{response.location}" if response.redirect?

        # Expect the redirect to occur
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(root_path(locale: :ja)) # or wherever it should redirect
      end
    end

    context 'when accessing schools with an unauthenticated user' do
      it 'allows access to JSON format without authentication' do
        # Simulate unauthenticated fetch request to JSON endpoint
        get '/schools', params: { format: :json }

        # No redirection should occur for JSON format
        expect(response).to have_http_status(:success)
        expect(response).not_to be_redirect
      end
    end
  end
end
