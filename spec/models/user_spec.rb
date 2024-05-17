# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end

  context 'when adding IP addresses' do
    it 'transforms newline separated IP addresses into an array' do
      user = create(:user, allowed_ips: "1.1.1.1\n2.2.2.2\n3.3.3.3")
      expect(user.allowed_ips).to eq(['1.1.1.1', '2.2.2.2', '3.3.3.3'])
    end

    it 'throw descriptive error if invalid IP address provided' do
      invalid_ip = build(:user, allowed_ips: 'invalid')
      invalid_ip.valid?
      expect(invalid_ip.errors[:allowed_ips]).to include('invalid is not a valid IP address')
    end

    it 'always returns an array even if only one step is passed' do
      user = create(:user, allowed_ips: '3.3.3.3')
      expect(user.allowed_ips).to eq(['3.3.3.3'])
    end

    it 'retains current IP addresses if none provided' do
      user = create(:user, allowed_ips: '')
      expect(user.allowed_ips).to eq([])
    end
  end
end
