# frozen_string_literal: true

require 'googleauth'
require 'stringio'

module PhotoService
  module GoogleCredentials
    module_function

    def for(scopes)
      credentials_json = Configuration.credentials_json
      if credentials_json.blank?
        raise ConfigurationError, 'Missing Google service account credentials'
      end

      Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(credentials_json),
        scope: scopes
      )
    end
  end
end
