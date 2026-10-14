# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Rashimba inquiry API' do
  include ActiveJob::TestHelper

  let(:headers) { { 'Origin' => 'https://rashimba.com' } }
  let(:path) { '/api/rashimba/sponsor_inquiries' }
  let(:payload) do
    {
      company: '株式会社Example', email: 'person@example.com', name: '山田 太郎',
      phone: '090-1234-5678', message: '資料を希望します', privacyConsent: 'accepted',
      submission_key: SecureRandom.uuid
    }
  end

  around do |example|
    original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
    example.run
  ensure
    ActiveJob::Base.queue_adapter = original_adapter
  end

  before do
    allow(RashimbaRecaptcha).to receive(:valid?).and_return(true)
  end

  it 'persists the sponsor form, consent timestamp, and queues delivery without exposing details' do
    expect do
      post path, params: payload.merge(status: 'resolved', notification_sent_at: Time.current),
                 headers:, as: :json
    end.to change(RashimbaInquiry, :count).by(1)
       .and have_enqueued_job(RashimbaInquiryDeliveryJob)

    expect(response).to have_http_status(:accepted)
    expect(response.body).not_to include(payload[:email])
    expect(RashimbaInquiry.last).to have_attributes(
      kind: 'sponsor', status: 'pending', company: payload[:company],
      privacy_consent: true, notification_sent_at: nil
    )
    expect(RashimbaInquiry.last.consented_at).to be_present
  end

  it 'accepts the exact parent form field names and optional age' do
    post '/api/rashimba/release_notifications', params: {
      email: ' Parent@Example.com ', child_age: '3-5', privacy_consent: 'agreed',
      submission_key: SecureRandom.uuid, company: 'Ignored'
    }, headers:, as: :json

    expect(response).to have_http_status(:accepted)
    expect(RashimbaInquiry.last).to have_attributes(
      kind: 'release_notification', email: 'parent@example.com', child_age: '3-5', company: nil
    )
  end

  it 'supports form-encoded posts from the existing form' do
    post(path, params: payload, headers:)
    expect(response).to have_http_status(:accepted)
  end

  it 'does not persist or queue duplicate submissions' do
    post path, params: payload, headers:, as: :json

    expect do
      post path, params: payload, headers:, as: :json
    end.not_to change(RashimbaInquiry, :count)
    expect(response).to have_http_status(:accepted)
    expect(enqueued_jobs.size).to eq(1)
  end

  it 'rejects reusing a submission key for a different payload' do
    post path, params: payload, headers:, as: :json
    post path, params: payload.merge(message: 'Changed'), headers:, as: :json
    expect(response).to have_http_status(:conflict)
    expect(RashimbaInquiry.count).to eq(1)
  end

  it 'rejects missing fields and consent without sending mail' do
    expect do
      post path, params: { email: 'bad', submission_key: SecureRandom.uuid }, headers:,
                 as: :json
    end.not_to change(RashimbaInquiry, :count)
    expect(response).to have_http_status(:unprocessable_entity)
    expect(enqueued_jobs).to be_empty
  end

  [false, nil, 'false', 'no', 'on'].each do |consent|
    it "rejects sponsor consent #{consent.inspect}" do
      post path, params: payload.merge(privacyConsent: consent), headers:, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(RashimbaInquiry.count).to eq(0)
    end
  end

  it 'rejects unsupported parent ages' do
    post '/api/rashimba/release_notifications', params: {
      email: 'parent@example.com', child_age: 'unknown', privacy_consent: 'agreed',
      submission_key: SecureRandom.uuid
    }, headers:, as: :json
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'rejects email header injection and oversized messages' do
    [payload.merge(email: "victim@example.com\r\nBcc: other@example.com"),
     payload.merge(message: 'x' * 5001)].each do |invalid|
      post path, params: invalid, headers:, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
    expect(RashimbaInquiry.count).to eq(0)
  end

  it 'rejects structured inputs instead of raising a server error' do
    post path, params: payload.merge(email: { malicious: 'value' }), headers:, as: :json
    expect(response).to have_http_status(:bad_request)
    post path, params: payload.merge(name: true), headers:, as: :json
    expect(response).to have_http_status(:bad_request)
  end

  it 'rejects unapproved and missing origins' do
    [{ 'Origin' => 'https://attacker.example' }, {}].each do |origin|
      post path, params: payload, headers: origin, as: :json
      expect(response).to have_http_status(:forbidden)
      expect(response.headers['Access-Control-Allow-Origin']).to be_nil
    end
    expect(RashimbaInquiry.count).to eq(0)
  end

  it 'allows only the configured frontend origin in the CORS preflight' do
    options path, headers: headers.merge(
      'Access-Control-Request-Method' => 'POST', 'Access-Control-Request-Headers' => 'content-type'
    )
    expect(response.headers['Access-Control-Allow-Origin']).to eq('https://rashimba.com')
    expect(response.headers['Access-Control-Allow-Credentials']).not_to eq('true')
  end

  it 'quietly discards honeypot submissions' do
    post path, params: payload.merge(website: 'https://spam.example'), headers:, as: :json
    expect(response).to have_http_status(:accepted)
    expect(RashimbaInquiry.count).to eq(0)
    expect(enqueued_jobs).to be_empty
  end

  it 'requires successful CAPTCHA verification' do
    allow(RashimbaRecaptcha).to receive(:valid?).and_return(false)
    post path, params: payload, headers:, as: :json
    expect(response).to have_http_status(:unprocessable_entity)
    expect(RashimbaInquiry.count).to eq(0)
  end

  it 'accepts both production forms without CAPTCHA when no secret is configured' do
    allow(Rails.env).to receive(:production?).and_return(true)
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('RASHIMBA_RECAPTCHA_SECRET_KEY', nil).and_return(nil)
    allow(RashimbaRecaptcha).to receive(:valid?).and_call_original

    post path, params: payload, headers:, as: :json
    expect(response).to have_http_status(:accepted)

    post '/api/rashimba/release_notifications', params: {
      email: 'parent@example.com', privacy_consent: 'agreed', submission_key: SecureRandom.uuid
    }, headers:, as: :json
    expect(response).to have_http_status(:accepted)
    expect(RashimbaInquiry.count).to eq(2)
  end

  it 'returns a retryable error when CAPTCHA is unavailable' do
    allow(RashimbaRecaptcha).to receive(:valid?).and_raise(RashimbaRecaptcha::Unavailable)
    post path, params: payload, headers:, as: :json
    expect(response).to have_http_status(:service_unavailable)
    expect(RashimbaInquiry.count).to eq(0)
  end

  it 'rolls back the inquiry if its email job cannot be queued' do
    allow(RashimbaInquiryDeliveryJob).to receive(:perform_later).and_return(false)
    post path, params: payload, headers:, as: :json
    expect(response).to have_http_status(:service_unavailable)
    expect(RashimbaInquiry.count).to eq(0)
  end

  it 'limits repeated submissions to the same email across both forms' do
    create_list(:rashimba_inquiry, 3, email: payload[:email])
    post path, params: payload, headers:, as: :json
    expect(response).to have_http_status(:too_many_requests)
    expect(response.headers['Retry-After']).to eq('3600')
    expect(RashimbaInquiry.count).to eq(3)
  end

  it 'limits an IP even when different email addresses are used' do
    create_list(:rashimba_inquiry, 10, ip_address: '127.0.0.1') do |inquiry, index|
      inquiry.update!(email: "person#{index}@example.com")
    end
    post path, params: payload, headers:, as: :json
    expect(response).to have_http_status(:too_many_requests)
    expect(RashimbaInquiry.count).to eq(10)
  end

  it 'rejects large requests' do
    post path, params: payload.merge(message: 'x' * 33.kilobytes), headers:, as: :json
    expect(response).to have_http_status(:payload_too_large)
  end

  it 'exposes no public list or details API' do
    get('/api/rashimba/sponsor_inquiries', headers:)
    expect(response).to have_http_status(:not_found)
  end
end
