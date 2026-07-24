# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Switching accounts' do
  it 'does not send the new account to a URL stored for the previous account' do
    previous_user = create(:customer)
    new_user = create(:customer, password: 'password123')
    new_user.confirm

    get user_path(id: previous_user.id)
    expect(response).to redirect_to(new_user_session_path)

    post user_session_path, params: {
      user: {
        email: new_user.email,
        password: 'password123'
      }
    }

    expect(response).to redirect_to(user_path(id: new_user.id))
  end

  it 'marks authenticated responses as non-cacheable' do
    user = create(:customer)
    sign_in user

    get user_path(id: user.id)

    expect(response.headers['Cache-Control']).to include('no-store')
    expect(response.body).to include("content='no-cache' name='turbo-cache-control'")
  end
end
