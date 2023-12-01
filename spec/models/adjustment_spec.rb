# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Adjustment do
  it 'has a valid factory' do
    expect(build(:adjustment)).to be_valid
  end

  it 'is valid with a negative change' do
    expect(build(:adjustment, change: -1)).to be_valid
  end

  it 'is invalid without a reason' do
    expect(build(:adjustment, reason: nil)).not_to be_valid
  end

  it 'is invalid without a change' do
    expect(build(:adjustment, change: nil)).not_to be_valid
  end

  it 'is invalid with a non-numerical change' do
    expect(build(:adjustment, change: 'a')).not_to be_valid
  end

  it 'is invalid without an invoice' do
    expect(build(:adjustment, invoice: nil)).not_to be_valid
  end
end
