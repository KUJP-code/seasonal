# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegularSchedule do
  it 'has a valid factory' do
    expect(build(:regular_schedule)).to be_valid
  end

  it 'normalizes the attendance month and allows one schedule per child and month' do
    schedule = create(:regular_schedule, month: Date.new(2026, 12, 25))
    expect(schedule.month).to eq(Date.new(2026, 12, 1))
    expect(build(:regular_schedule, child: schedule.child,
                                    month: Date.new(2026, 12, 1))).not_to be_valid
    expect(build(:regular_schedule, child: schedule.child, month: Date.new(2027, 1, 1))).to be_valid
    expect(build(:regular_schedule, month: nil)).not_to be_valid
  end

  it 'defaults to the next attendance month from the 21st, including year boundaries' do
    expect(described_class.default_month(Date.new(2026, 11, 20))).to eq(Date.new(2026, 11, 1))
    expect(described_class.default_month(Date.new(2026, 11, 21))).to eq(Date.new(2026, 12, 1))
    expect(described_class.default_month(Date.new(2026, 12, 25))).to eq(Date.new(2027, 1, 1))
    expect(described_class.default_month(Date.new(2026, 12, 2))).to eq(Date.new(2026, 12, 1))
  end

  context 'when checking for regular days with #has?' do
    let(:schedule) { build(:regular_schedule, month: Date.new(2024, 9, 1), monday: true) }

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

    it 'does not apply the same weekdays to a different month or year' do
      expect(schedule.has?(Date.new(2024, 10, 7))).to be false
      expect(schedule.has?(Date.new(2025, 9, 8))).to be false
      schedule.month = nil
      expect(schedule.has?(Date.new(2024, 9, 9))).to be false
    end
  end
end
