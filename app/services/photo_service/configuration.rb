# frozen_string_literal: true

module PhotoService
  class ConfigurationError < StandardError; end

  module Configuration
    DEFAULT_SPREADSHEET_ID = '1LsVHxrYwYz3WQXu8n9Vad_hCuRXJyLRtdTJBVFZt3V0'
    DEFAULT_CACHE_TTL = 10.minutes
    DEFAULT_PICTURES_CACHE_TTL = 5.minutes
    DEFAULT_PAGE_SIZE = 1000

    module_function

    def spreadsheet_id
      ENV.fetch('PHOTO_SERVICE_SPREADSHEET_ID', DEFAULT_SPREADSHEET_ID)
    end

    def cache_ttl
      ENV.fetch('PHOTO_SERVICE_CACHE_TTL_SECONDS', DEFAULT_CACHE_TTL.to_i).to_i.seconds
    end

    def pictures_cache_ttl
      ENV.fetch(
        'PHOTO_SERVICE_PICTURES_CACHE_TTL_SECONDS',
        DEFAULT_PICTURES_CACHE_TTL.to_i
      ).to_i.seconds
    end

    def page_size
      ENV.fetch('PHOTO_SERVICE_PAGE_SIZE', DEFAULT_PAGE_SIZE).to_i
    end

    def credentials_json
      ENV['GOOGLE_SERVICE_ACCOUNT_JSON'].presence ||
        Rails.application.credentials.dig(:google, :service_account_json).presence ||
        credentials_file_json
    end

    def credentials_file_json
      path = ENV['GOOGLE_APPLICATION_CREDENTIALS'].presence
      return if path.blank?

      File.read(path)
    end
  end
end
