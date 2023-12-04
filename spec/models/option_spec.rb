# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Option do
  context 'when using factory for tests' do
    it 'has a valid slot option factory' do
      expect(build(:slot_option)).to be_valid
    end

    it 'has a valid event option factory' do
      expect(build(:event_option)).to be_valid
    end
  end
end
