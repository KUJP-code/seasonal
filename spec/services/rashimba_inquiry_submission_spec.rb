# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RashimbaInquirySubmission do
  around do |example|
    original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :solid_queue
    example.run
  ensure
    ActiveJob::Base.queue_adapter = original_adapter
  end

  it 'commits the inquiry and the Solid Queue job in the same database transaction' do
    inquiry = build(:rashimba_inquiry)
    expect do
      described_class.call(inquiry)
    end.to change(RashimbaInquiry, :count).by(1).and change(SolidQueue::Job, :count).by(1)
    expect(SolidQueue::Job.last.class_name).to eq('RashimbaInquiryDeliveryJob')
  end

  it 'rolls back both the inquiry and the enqueued job if acceptance fails' do
    inquiry = build(:rashimba_inquiry)
    allow(RashimbaInquiryDeliveryJob).to receive(:perform_later)
      .and_wrap_original do |original, *args|
      original.call(*args)
      raise ActiveJob::EnqueueError, 'Acceptance failed'
    end
    expect do
      described_class.call(inquiry)
    end.to raise_error(ActiveJob::EnqueueError)
    expect(RashimbaInquiry.count).to eq(0)
    expect(SolidQueue::Job.count).to eq(0)
  end
end
