# frozen_string_literal: true

module Api
  class RashimbaInquiriesController < ActionController::API
    CONSENT_FIELDS = %i[privacyConsent privacy_consent].freeze
    BOOLEAN_VALUES = [true, false].freeze
    EXTRA_FIELDS = %i[submission_key recaptcha_token website].freeze

    before_action :check_origin
    before_action :check_request_size

    rescue_from ActionController::BadRequest, with: :bad_request
    rescue_from RashimbaInquirySubmission::RateLimited do
      response.set_header('Retry-After', '3600')
      render json: { errors: ['送信回数の上限に達しました。時間をおいてお試しください。'] },
             status: :too_many_requests
    end
    rescue_from RashimbaInquirySubmission::Conflict do
      render json: { errors: ['送信内容が変更されています。再度送信してください。'] }, status: :conflict
    end
    rescue_from RashimbaRecaptcha::Unavailable, ActiveJob::EnqueueError,
                SolidQueue::Job::EnqueueError do
      render json: { errors: ['現在送信できません。時間をおいてお試しください。'] },
             status: :service_unavailable
    end

    def sponsor
      submit('sponsor', %i[company email name phone message], :privacyConsent, 'accepted')
    end

    def release_notification
      submit('release_notification', %i[email child_age], :privacy_consent, 'agreed')
    end

    private

    def submit(kind, fields, consent_field, consent_value)
      attributes = scalar_params(fields + [consent_field] + EXTRA_FIELDS)
      return accepted if attributes.delete(:website).present?

      token = attributes.delete(:recaptcha_token)
      inquiry = build_inquiry(attributes, kind, consent_field, consent_value)
      return invalid(inquiry) unless inquiry.valid?
      return unless check_captcha(inquiry, token)

      saved = RashimbaInquirySubmission.call(inquiry)
      saved.persisted? ? accepted : invalid(saved)
    end

    def build_inquiry(attributes, kind, consent_field, consent_value)
      consent = attributes.delete(consent_field)
      attributes[:privacy_consent] = [true, consent_value].include?(consent)
      inquiry = RashimbaInquiry.new(attributes.merge(kind:, consented_at: Time.current,
                                                     ip_address: request.remote_ip))
      inquiry.submission_digest = Digest::SHA256.hexdigest(
        attributes.except(:submission_key).merge(kind:).sort.to_json
      )
      inquiry
    end

    def check_captcha(inquiry, token)
      if RashimbaRecaptcha.valid?(token:, ip_address: request.remote_ip,
                                  action: "rashimba_#{inquiry.kind}")
        return true
      end

      render json: { errors: ['認証に失敗しました。もう一度お試しください。'] }, status: :unprocessable_entity
      false
    end

    def scalar_params(fields)
      fields.each_with_object({}) do |field, values|
        value = params[field]
        raise ActionController::BadRequest unless scalar_value?(field, value)

        values[field] = value
      end
    end

    def scalar_value?(field, value)
      value.nil? || value.is_a?(String) ||
        (CONSENT_FIELDS.include?(field) && BOOLEAN_VALUES.include?(value))
    end

    def check_origin
      response.set_header('Cache-Control', 'no-store')
      return if Rails.configuration.x.rashimba_origins.include?(request.headers['Origin'])

      render json: { errors: ['Origin is not allowed.'] }, status: :forbidden
    end

    def check_request_size
      return if request.raw_post.bytesize <= 32.kilobytes

      render json: { errors: ['Request is too large.'] }, status: :payload_too_large
    end

    def accepted
      render json: { status: 'accepted', message: '送信を受け付けました。確認メールをお送りします。' }, status: :accepted
    end

    def invalid(inquiry)
      render json: { errors: inquiry.errors.full_messages }, status: :unprocessable_entity
    end

    def bad_request
      render json: { errors: ['Invalid request.'] }, status: :bad_request
    end
  end
end
