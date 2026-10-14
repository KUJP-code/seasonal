# frozen_string_literal: true

require 'digest'

class RashimbaInquirySubmission
  class RateLimited < StandardError; end
  class Conflict < StandardError; end

  def self.call(inquiry)
    new(inquiry).call
  end

  def initialize(inquiry)
    @inquiry = inquiry
  end

  def call
    return @inquiry unless @inquiry.valid?

    RashimbaInquiry.transaction do
      lock_submission
      existing = RashimbaInquiry.find_by(submission_key: @inquiry.submission_key)
      if existing
        raise Conflict unless existing.submission_digest == @inquiry.submission_digest

        next existing
      end
      enforce_limits
      @inquiry.save!
      # Solid Queue uses this application's database, so enqueue and insert commit together.
      job = RashimbaInquiryDeliveryJob.perform_later(@inquiry.id)
      raise ActiveJob::EnqueueError, 'Inquiry delivery could not be queued' unless job

      @inquiry
    end
  end

  private

  def lock_submission
    ["ip:#{@inquiry.ip_address}", "email:#{@inquiry.email}", "key:#{@inquiry.submission_key}"]
      .sort.each do |value|
      key = Digest::SHA256.hexdigest("rashimba:#{value}")[0, 15].to_i(16)
      RashimbaInquiry.connection.execute("SELECT pg_advisory_xact_lock(#{key})")
    end
  end

  def enforce_limits
    recent = RashimbaInquiry.where(created_at: 1.hour.ago..)
    return if recent.where(ip_address: @inquiry.ip_address).count < 10 &&
              recent.where(email: @inquiry.email).count < 3

    raise RateLimited
  end
end
