# frozen_string_literal:true

require 'rails_helper'

RSpec.describe QrCodeUsage do
  context 'validations' do
    it 'must belong to a QrCode' do
      usage = build(:qr_code_usage, qr_code: nil)
      expect(usage).not_to be_valid
      expect(usage.errors[:qr_code]).to include('を入力してください')
    end
  end

  context 'timestamps' do
    it 'automatically sets created_at' do
      usage = create(:qr_code_usage)
      expect(usage.created_at).not_to be_nil
    end
  end
end
