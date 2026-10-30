# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Child do
  subject(:child) { create(:internal_child) }

  let(:january_monday) { Date.new(2027, 1, 4) }

  it 'uses the most recent earlier month when the activity month has no schedule' do
    create(:regular_schedule, child:, month: Date.new(2026, 11, 1), tuesday: true)
    latest = create(:regular_schedule, child:, month: Date.new(2026, 12, 1), monday: true)

    expect(child.regular_schedule_for(january_monday)).to eq(latest)
    expect(child.regular_day?(january_monday)).to be(true)
    expect(child.regular_day?(Date.new(2027, 1, 5))).to be(false)
  end

  it 'accepts schedules five calendar months earlier, including across year boundaries' do
    august = create(:regular_schedule, child:, month: Date.new(2026, 8, 1), monday: true)

    expect(child.regular_schedule_for(january_monday)).to eq(august)
    expect(child.regular_day?(january_monday)).to be(true)
  end

  it 'ignores schedules older than five months' do
    create(:regular_schedule, child:, month: Date.new(2026, 7, 1), monday: true)

    expect(child.regular_schedule_for(january_monday)).to be_nil
    expect(child.regular_day?(january_monday)).to be(false)
  end

  it 'prioritizes an exact month without merging weekdays with older schedules' do
    create(:regular_schedule, child:, month: Date.new(2026, 12, 1), monday: true)
    january = create(:regular_schedule, child:, month: Date.new(2027, 1, 1), tuesday: true)

    expect(child.regular_schedule_for(january_monday)).to eq(january)
    expect(child.regular_day?(january_monday)).to be(false)
    expect(child.regular_day?(Date.new(2027, 1, 5))).to be(true)
  end

  it 'does not revive older weekdays after a newer schedule explicitly clears all days' do
    create(:regular_schedule, child:, month: Date.new(2026, 11, 1), monday: true)
    cleared = create(:regular_schedule, child:, month: Date.new(2026, 12, 1))

    expect(child.regular_schedule_for(january_monday)).to eq(cleared)
    expect(child.regular_day?(january_monday)).to be(false)
  end

  it 'keeps an exact-month no-days schedule instead of falling back' do
    create(:regular_schedule, child:, month: Date.new(2026, 12, 1), monday: true)
    cleared = create(:regular_schedule, child:, month: Date.new(2027, 1, 1))

    expect(child.regular_schedule_for(january_monday)).to eq(cleared)
    expect(child.regular_day?(january_monday)).to be(false)
  end

  it 'does not apply a later schedule backward to earlier activity months' do
    create(:regular_schedule, child:, month: Date.new(2027, 2, 1), monday: true)

    expect(child.regular_schedule_for(january_monday)).to be_nil
    expect(child.regular_day?(january_monday)).to be(false)
  end

  it 'ignores undated legacy schedules and weekends' do
    child.regular_schedules.build(monday: true).save!(validate: false)
    expect(child.regular_schedule_for(january_monday)).to be_nil

    child.regular_schedules.create!(month: Date.new(2026, 12, 1), monday: true)
    expect(child.regular_day?(Date.new(2027, 1, 2))).to be(false)
    expect(child.regular_day?(Date.new(2027, 1, 3))).to be(false)
  end

  it 'uses earlier historical weekdays without borrowing later schedules' do
    create(:regular_schedule, child:, month: Date.new(2026, 8, 1), monday: true)
    create(:regular_schedule, child:, month: Date.new(2027, 1, 1), tuesday: true)

    expect(child.regular_day?(Date.new(2026, 9, 7))).to be(true)
    expect(child.regular_day?(Date.new(2026, 9, 8))).to be(false)
  end
end
