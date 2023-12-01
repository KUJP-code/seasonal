# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Registration do
  it 'has a valid factory for slot regs' do
    expect(build(:slot_reg)).to be_valid
  end

  it 'has a valid factory for option regs' do
    expect(build(:opt_reg)).to be_valid
  end

  it 'is invalid without a child' do
    expect(build(:registration, child: nil)).not_to be_valid
  end

  it 'is invalid without a registerable' do
    expect(build(:registration, registerable: nil)).not_to be_valid
  end

  it 'is invalid when child already registered for that slot' do
    slot = create(:time_slot)
    child = create(:child)
    build(:slot_reg, child: child, registerable: slot).save
    expect(build(:slot_reg, child: child, registerable: slot)).not_to be_valid
  end

  it 'is invalid when child already registered for that option' do
    option = create(:slot_option)
    child = create(:child)
    create(:opt_reg, child: child, registerable: option)
    expect(build(:opt_reg, child: child, registerable: option)).not_to be_valid
  end
end
