# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Automated invoice emails' do
  let!(:invoice) { create(:invoice, child: create(:child, parent: create(:customer))) }

  it 'only sends a confirmation email when invoice confirmed' do
    user = create(:school_manager, allowed_ips: ['*'])
    sign_in user
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    patch invoice_path(id: invoice.id, params:
                       { invoice: { in_ss: 'true', email_sent: 'true' } })
    expect(ActiveJob::Base.queue_adapter.enqueued_jobs
      .count { |j| j['job_class'] == 'ActionMailer::MailDeliveryJob' }).to eq(1)
  end

  it 'only sends update emails to SM/parent when modified' do
    user = create(:customer)
    user.children << invoice.child
    sign_in user
    child_id = create(:child).id
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    patch invoice_path(id: invoice.id, params:
                       { invoice: { child_id: } })
    expect(ActiveJob::Base.queue_adapter.enqueued_jobs
      .count { |j| j['job_class'] == 'ActionMailer::MailDeliveryJob' }).to eq(2)
  end
end
