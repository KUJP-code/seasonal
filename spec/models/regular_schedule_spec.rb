# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegularSchedule do
  let(:child) { create(:child) }

  it 'knows its child' do
    schedule = child.create_regular_schedule(attributes_for(:regular_schedule))
    schedule_child = schedule.child
    expect(schedule_child).to eq child
  end

  it 'attendance saves as false by default' do
    default = child.create_regular_schedule
    default_monday = default.monday
    expect(default_monday).to be false
  end
end
