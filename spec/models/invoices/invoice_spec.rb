# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice do
  it 'has a valid factory' do
    expect(build(:invoice)).to be_valid
  end
end
