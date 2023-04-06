# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CsvsController do
  describe 'GET #download' do
    it 'returns http success' do
      get :download
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #upload' do
    it 'returns http success' do
      get :upload
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
