# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecentFinishedSeasonalAttendanceJob do
  include ActiveJob::TestHelper

  def create_real_invoice(child:, event:)
    slot = create(:time_slot, event:)
    invoice = create(:invoice, child:, event:)
    create(:slot_reg, child:, invoice:, registerable: slot)
    invoice
  end

  def create_finished_event(attributes = {})
    event = create(:event, attributes.except(:start_date, :end_date))
    end_date = attributes.fetch(:end_date)
    event.update_columns(
      start_date: attributes.fetch(:start_date, end_date - 1.day),
      end_date:
    )
    event
  end

  it 'marks first seasonal children from recently finished seasonals' do
    event = create_finished_event(end_date: 1.week.ago.to_date, early_bird_discount: 0)
    child = create(:child, first_seasonal: true)
    create_real_invoice(child:, event:)

    perform_enqueued_jobs { described_class.perform_later }

    expect(child.reload.first_seasonal).to be(false)
  end

  it 'does not update children from seasonals outside the lookback window' do
    event = create_finished_event(end_date: 2.months.ago.to_date, early_bird_discount: 0)
    child = create(:child, first_seasonal: true)
    create_real_invoice(child:, event:)

    perform_enqueued_jobs { described_class.perform_later }

    expect(child.reload.first_seasonal).to be(true)
  end

  it 'does not update children from non-seasonal events' do
    event = create_finished_event(end_date: 1.week.ago.to_date, early_bird_discount: -1000)
    child = create(:child, first_seasonal: true)
    create_real_invoice(child:, event:)

    perform_enqueued_jobs { described_class.perform_later }

    expect(child.reload.first_seasonal).to be(true)
  end

  it 'matches the manual button behavior by updating all events with a recent seasonal name' do
    recent_event = create_finished_event(name: 'Summer School',
                                         end_date: 1.week.ago.to_date,
                                         early_bird_discount: 0)
    same_name_event = create_finished_event(name: recent_event.name, end_date: 2.months.ago.to_date)
    child = create(:child, first_seasonal: true)
    create_real_invoice(child:, event: same_name_event)

    perform_enqueued_jobs { described_class.perform_later }

    expect(child.reload.first_seasonal).to be(false)
  end
end
