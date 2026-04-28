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
      expect(invalid_ip.errors[:allowed_ips]).to include(' invalid is not a valid IP address')
    end

    it 'always returns an array even if only one step is passed' do
      user = create(:user, allowed_ips: '3.3.3.3')
      expect(user.allowed_ips).to eq(['3.3.3.3'])
    end

    it 'retains current IP addresses if none provided' do
      user = create(:user, allowed_ips: '')
      expect(user.allowed_ips).to eq([])
    end

    it 'allows wildcard (*) as a valid IP address' do
      user = create(:user, allowed_ips: '*')
      expect(user.allowed_ips).to eq(['*'])
    end

    it 'allows wildcard (*) to be included with other IPs' do
      user = create(:user, allowed_ips: "1.1.1.1\n*")
      expect(user.allowed_ips).to eq(['1.1.1.1', '*'])
    end
  end

  describe '#recruiter_access?' do
    it 'allows human resources users' do
      expect(build(:human_resources)).to be_recruiter_access
    end

    it 'allows area managers with recruiter privileges' do
      expect(build(:area_manager, :recruiter_privileges)).to be_recruiter_access
    end

    it 'allows statisticians with recruiter privileges' do
      expect(build(:statistician, :recruiter_privileges)).to be_recruiter_access
    end

    it 'does not allow customers even if the flag is set' do
      user = build(:customer, recruiter_privileges: true)

      expect(user).not_to be_recruiter_access
    end
  end

  describe 'recruiter privileges' do
    it 'clears the flag for customers' do
      user = build(:customer, recruiter_privileges: true)

      user.valid?

      expect(user).not_to be_recruiter_privileges
    end

    it 'clears the flag for school managers' do
      user = build(:school_manager, recruiter_privileges: true)

      user.valid?

      expect(user).not_to be_recruiter_privileges
    end

    it 'keeps the flag for area managers' do
      user = build(:area_manager, :recruiter_privileges)

      user.valid?

      expect(user).to be_recruiter_privileges
    end
  end
end
