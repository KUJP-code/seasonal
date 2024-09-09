# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegularSchedule do
  it 'has a valid factory' do
    expect(build(:regular_schedule)).to be_valid
  end

  context 'when checking for regular days with #has?' do
    let(:schedule) { build(:regular_schedule, monday: true) }

    it 'returns true if day is present in schedule' do
      monday = Date.parse('2024-09-09')
      expect(schedule.has?(monday)).to be true
    end

    it 'returns false if day is not present in schedule' do
      tuesday = Date.parse('2024-09-10')
      expect(schedule.has?(tuesday)).to be false
    end

    it 'returns false for Saturday' do
      saturday = Date.parse('2024-09-14')
      expect(schedule.has?(saturday)).to be false
    end

    it 'returns false for Sunday' do
      sunday = Date.parse('2024-09-15')
      expect(schedule.has?(sunday)).to be false
    end
  end
end
