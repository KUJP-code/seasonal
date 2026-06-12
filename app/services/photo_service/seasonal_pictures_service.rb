# frozen_string_literal: true

module PhotoService
  class SeasonalPicturesService
    def initialize(drive_client: DriveClient.new)
      @drive_client = drive_client
    end

    def call(activities)
      successful_activities = activities.filter_map do |activity|
        activity_with_files(activity)
      end

      successful_activities.sort_by { |activity| sort_key(activity[:date]) }
    end

    private

    attr_reader :drive_client

    def activity_with_files(activity)
      activity = activity.to_h.symbolize_keys
      files = drive_client.pictures_in_folder(activity[:folder_id])
      return if files.empty?

      activity.merge(files:)
    rescue StandardError => e
      Rails.logger.error(
        "[photo_service] folder #{activity[:folder_id]} failed: #{e.class}: #{e.message}"
      )
      nil
    end

    def sort_key(date)
      [
        date.to_s,
        date.to_s.include?('(AM)') ? 0 : 1
      ]
    end
  end
end
