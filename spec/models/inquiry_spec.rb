# frozen_string_literal: true

require 'rails_helper'

describe Inquiry do
  it 'has a valid factory' do
    expect(build(:inquiry)).to be_valid
  end
end
