# frozen_string_literal: true

module PhotoService
  class LoginService
    def initialize(sheets_client: SheetsClient.new)
      @sheets_client = sheets_client
    end

    def login(code)
      code = code.to_s.strip
      return failure('Incorrect Login Code') if code.blank?

      photo_expiry_dates = expiry_dates
      result = code.length <= 8 ? party_login(code) : seasonal_login(code)

      return result unless result[:success]

      result.merge(
        expiryDate: code.length <= 8 ? photo_expiry_dates[:party] : photo_expiry_dates[:seasonal]
      )
    end

    private

    attr_reader :sheets_client

    def expiry_dates
      variables_data = sheets_client.sheet_data('displayVariables')

      {
        seasonal: variables_data.dig(1, 1),
        party: variables_data.dig(1, 2)
      }
    end

    def seasonal_login(code)
      missing_tab = missing_seasonal_tab_failure
      return missing_tab if missing_tab

      school = school_for_seasonal_code(code)
      return failure('Incorrect Login Code') if school.blank?

      school_sheet_data = sheets_client.sheet_data(school)
      return failure('School data format error or missing') unless school_sheet_data.length > 1

      activities = seasonal_activities_for(school_sheet_data)

      {
        success: true,
        school:,
        activities:
      }
    rescue StandardError => e
      Rails.logger.error("[photo_service] seasonal login failed: #{e.class}: #{e.message}")
      failure('An error occurred')
    end

    def missing_seasonal_tab_failure
      return if sheets_client.tab_names.include?('SSData')

      failure('SSData tab not found in the spreadsheet')
    end

    def school_for_seasonal_code(code)
      ssdata_values = sheets_client.sheet_data('SSData')
      matching_row = ssdata_values.find { |row| row.include?(code) }

      matching_row&.[](2)
    end

    def seasonal_activities_for(school_sheet_data)
      folder_id_row = school_sheet_data[3] || []

      activity_name_dates_for(school_sheet_data).filter_map do |activity|
        date_index = school_sheet_data[0]&.index(activity[:date])
        next if date_index.blank?

        folder_id = folder_id_row[date_index]
        next if folder_id.blank?

        activity.merge(folder_id:)
      end
    end

    def party_login(code)
      matching_tabs.each do |tab_name|
        result = party_login_for_tab(tab_name, code)
        return result if result.present?
      end

      failure('No matching code found')
    rescue StandardError => e
      Rails.logger.error("[photo_service] party login failed: #{e.class}: #{e.message}")
      failure('An error occurred')
    end

    def matching_tabs
      display_variables = sheets_client.sheet_data('displayVariables').filter_map do |row|
        row[0].to_s.strip.presence
      end

      display_variables & sheets_client.tab_names
    end

    def party_login_for_tab(tab_name, code)
      tab_data = sheets_client.sheet_data(tab_name)

      tab_data.each_with_index do |row, row_index|
        column_index = row.index(code)
        next if column_index.blank?

        return party_folder_for(tab_data, row_index, column_index)
      end

      nil
    end

    def party_folder_for(tab_data, row_index, column_index)
      school_name = tab_data.dig(row_index, 0).to_s.strip
      party_name = tab_data.dig(0, column_index).to_s.strip
      school_sheet_data = sheets_client.sheet_data(school_name)
      header_index = school_sheet_data[0]&.index(party_name)
      folder_id = school_sheet_data.dig(1, header_index) if header_index.present?

      return failure('No matching code found') if folder_id.blank?

      {
        success: true,
        folder_id:,
        school: school_name
      }
    end

    def activity_name_dates_for(school_sheet_data)
      headers = school_sheet_data[0] || []

      headers.each_index.filter_map do |column_index|
        column = school_sheet_data.pluck(column_index)
        next unless activity_column?(column)

        {
          date: column[1].strip,
          name: column[2].strip
        }
      end
    end

    def activity_column?(column)
      column.length >= 4 &&
        column[1].present? &&
        column[2].present? &&
        column[3].present?
    end

    def failure(message)
      { success: false, message: }
    end
  end
end
