# frozen_string_literal: true

require 'google/apis/drive_v3'

module PhotoService
  class DriveClient
    DRIVE_SCOPE = 'https://www.googleapis.com/auth/drive.readonly'

    def pictures_in_folder(folder_id)
      folder_id = folder_id.to_s.strip
      return [] if folder_id.blank?

      Rails.cache.fetch(cache_key(folder_id), expires_in: Configuration.pictures_cache_ttl) do
        files = list_folder_files(folder_id)
        files.map { |file| file_payload(file) }
      end
    end

    private

    def list_folder_files(folder_id)
      response = service.list_files(
        q: "'#{escaped(folder_id)}' in parents and mimeType='image/jpeg' and trashed=false",
        fields: 'files(id,name,mimeType),nextPageToken',
        supports_all_drives: true,
        include_items_from_all_drives: true,
        page_size: Configuration.page_size
      )
      response.files || []
    end

    def service
      @service ||= Google::Apis::DriveV3::DriveService.new.tap do |drive|
        drive.authorization = GoogleCredentials.for(DRIVE_SCOPE)
      end
    end

    def file_payload(file)
      {
        name: file.name,
        id: file.id,
        mimeType: file.mime_type,
        thumbnailUrl: "https://drive.google.com/thumbnail?id=#{file.id}",
        imageUrl: "https://drive.google.com/uc?id=#{file.id}"
      }
    end

    def escaped(value)
      value.gsub('\\', '\\\\\\').gsub("'", "\\\\'")
    end

    def cache_key(folder_id)
      ['photo_service', 'drive', folder_id]
    end
  end
end
