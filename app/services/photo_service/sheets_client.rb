# frozen_string_literal: true

require 'google/apis/sheets_v4'

module PhotoService
  class SheetsClient
    SHEETS_SCOPE = 'https://www.googleapis.com/auth/spreadsheets.readonly'

    def sheet_data(sheet_name)
      Rails.cache.fetch(cache_key('sheet', sheet_name), expires_in: Configuration.cache_ttl) do
        response = service.get_spreadsheet_values(
          Configuration.spreadsheet_id,
          sheet_name
        )
        response.values || []
      end
    end

    def tab_names
      Rails.cache.fetch(cache_key('tabs'), expires_in: Configuration.cache_ttl) do
        response = service.get_spreadsheet(
          Configuration.spreadsheet_id,
          fields: 'sheets.properties.title'
        )
        response.sheets.map { |sheet| sheet.properties.title }
      end
    end

    private

    def service
      @service ||= Google::Apis::SheetsV4::SheetsService.new.tap do |sheets|
        sheets.authorization = GoogleCredentials.for(SHEETS_SCOPE)
      end
    end

    def cache_key(*parts)
      ['photo_service', 'sheets', Configuration.spreadsheet_id, *parts]
    end
  end
end
