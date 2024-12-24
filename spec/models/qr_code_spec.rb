# frozen_string_literal:true

require 'rails_helper'

RSpec.describe QrCode do
  context 'validations' do
    it 'requires a name' do
      qr = build(:qr_code, name: nil)
      expect(qr).not_to be_valid
      expect(qr.errors[:name]).to include('を入力してください')
    end

    it 'requires a unique name' do
      create(:qr_code, name: 'unique')
      duplicate = build(:qr_code, name: 'unique')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include('はすでに存在します')
    end
  end

  context 'associations' do
    it 'has many qr_code_usages' do
      association = described_class.reflect_on_association(:qr_code_usages)
      expect(association.macro).to eq(:has_many)
    end
  end
end
