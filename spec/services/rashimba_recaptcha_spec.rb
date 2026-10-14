# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RashimbaRecaptcha do
  let(:http) { instance_double(Net::HTTP) }
  let(:result) do
    { success: true, action: 'rashimba_sponsor', score: 0.9, hostname: 'rashimba.com' }
  end

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('RASHIMBA_RECAPTCHA_SECRET_KEY',
                                       nil).and_return('test-secret')
    allow(Net::HTTP).to receive(:start).and_yield(http)
    response = Net::HTTPOK.new('1.1', '200', 'OK')
    allow(response).to receive(:body) { result.to_json }
    allow(http).to receive(:request).and_return(response)
  end

  def verify
    described_class.valid?(token: 'test-token', ip_address: '192.0.2.1', action: 'rashimba_sponsor')
  end

  it 'accepts a successful token for this hostname and action' do
    expect(verify).to be(true)
  end

  it 'rejects tokens for another site or form, and low scores' do
    result[:hostname] = 'attacker.example'
    expect(verify).to be(false)
    result[:hostname] = 'rashimba.com'
    result[:action] = 'other_form'
    expect(verify).to be(false)
    result[:action] = 'rashimba_sponsor'
    result[:score] = 0.1
    expect(verify).to be(false)
  end

  it 'allows submissions without a token when the production secret is absent' do
    allow(Rails.env).to receive(:production?).and_return(true)
    allow(ENV).to receive(:fetch).with('RASHIMBA_RECAPTCHA_SECRET_KEY', nil).and_return(nil)
    expect(described_class.valid?(token: '', ip_address: '192.0.2.1', action: 'rashimba_sponsor'))
      .to be(true)
    expect(Net::HTTP).not_to have_received(:start)
  end

  it 'turns a network failure into a retryable service error' do
    allow(Net::HTTP).to receive(:start).and_raise(Net::ReadTimeout)
    expect { verify }.to raise_error(described_class::Unavailable)
  end

  it 'requires a token whenever a secret is configured' do
    expect(described_class.valid?(token: '', ip_address: '192.0.2.1', action: 'rashimba_sponsor'))
      .to be(false)
  end
end
