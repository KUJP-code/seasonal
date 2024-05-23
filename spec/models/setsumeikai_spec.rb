# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Setsumeikai do
  subject(:setsumeikai) { build(:setsumeikai) }

  it { is_expected.to be_valid }

  it 'automatically sets time component of close_at to 6pm' do
    setsumeikai.save
    expect(setsumeikai.close_at.strftime('%H:%M')).to eq('18:00')
  end

  context 'when using full?' do
    it 'is full when inquiries_count == attendance_limit' do
      setsumeikai.inquiries_count = setsumeikai.attendance_limit
      expect(setsumeikai.full?).to be true
    end

    it 'is full when inquiries_count > attendance_limit' do
      setsumeikai.inquiries_count = setsumeikai.attendance_limit + 1
      expect(setsumeikai.full?).to be true
    end

    it 'is full when past close_at' do
      setsumeikai.close_at = Time.zone.now
      expect(setsumeikai.full?).to be true
    end

    it 'is not full when inquiries_count < attendance_limit' do
      setsumeikai.inquiries_count = setsumeikai.attendance_limit - 1
      expect(setsumeikai.full?).to be false
    end

    it 'is not full when before close_at' do
      setsumeikai.close_at = 1.hour.from_now
      expect(setsumeikai.full?).to be false
    end
  end

  context 'when using calendar scope' do
    it 'excludes setsumeikais with future release date' do
      setsumeikai.release_date = 1.day.from_now
      setsumeikai.start = 2.days.from_now
      setsumeikai.save
      expect(described_class.calendar).not_to include(setsumeikai)
    end

    it 'returns setsumeikais whose release date is today' do
      setsumeikai.release_date = Time.zone.today
      setsumeikai.start = 2.days.from_now
      setsumeikai.save
      expect(described_class.calendar).to include(setsumeikai)
    end

    it 'returns setsumeikais whose release date passed' do
      setsumeikai.release_date = 1.day.ago
      setsumeikai.start = 2.days.from_now
      setsumeikai.save
      expect(described_class.calendar).to include(setsumeikai)
    end
  end
end
