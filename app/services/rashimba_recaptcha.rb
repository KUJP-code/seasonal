# frozen_string_literal: true

require 'net/http'

class RashimbaRecaptcha
  class Unavailable < StandardError; end

  def self.valid?(token:, ip_address:, action:)
    new.valid?(token:, ip_address:, action:)
  end

  def valid?(token:, ip_address:, action:)
    secret = ENV.fetch('RASHIMBA_RECAPTCHA_SECRET_KEY', nil)
    return true if secret.blank?
    return false if token.blank?

    valid_result?(verification_result(token, ip_address, secret), action)
  rescue IOError, SystemCallError, Timeout::Error, OpenSSL::SSL::SSLError, JSON::ParserError
    raise Unavailable
  end

  private

  def verification_result(token, ip_address, secret)
    uri = URI('https://www.google.com/recaptcha/api/siteverify')
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true,
                                                   open_timeout: 3, read_timeout: 3) do |http|
      request = Net::HTTP::Post.new(uri)
      request.set_form_data(secret:, response: token, remoteip: ip_address)
      http.request(request)
    end
    raise Unavailable unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end

  def valid_result?(result, action)
    hostnames = Rails.configuration.x.rashimba_origins.map { |origin| URI(origin).host }
    result['success'] == true && result['action'] == action &&
      result['score'].to_f >= 0.5 && hostnames.include?(result['hostname'])
  end
end
