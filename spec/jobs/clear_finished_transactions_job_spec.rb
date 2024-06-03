# frozen_string_literal: true

require 'rails_helper'

class TestJob < ApplicationJob; end

RSpec.describe ClearFinishedTransactionsJob do
  include ActiveJob::TestHelper

  let(:invoice) { create(:invoice) }

  it 'clears finished jobs older than 7 days when run' do
    job = SolidQueue::Job.create(class_name: TestJob.name, queue_name: 'default',
                                 finished_at: 8.days.ago)
    perform_enqueued_jobs do
      described_class.perform_later
    end

    expect(SolidQueue::Job.exists?(job.id)).to be false
  end

  it 'does not clear finished jobs younger than 7 days when run' do
    job = SolidQueue::Job.create(class_name: TestJob.name, queue_name: 'default',
                                 finished_at: 6.days.ago)
    perform_enqueued_jobs do
      described_class.perform_later
    end

    expect(SolidQueue::Job.exists?(job.id)).to be true
  end
end
