# frozen_string_literal: true

# Handles direct uploads to ActiveStorage
class UploadsController < ApplicationController
  def new
    @folders = [%w[Assets assets], ['Time Slots', 'time_slots'], %w[Events events]]
    @events = [['Summer 2023', 'summer_2023'], ['Winter 2023', 'winter_2023']]
  end

  def create
    @uploads = params[:uploads]
    @folder = params[:folder]
    @event = params[:event]

    @uploads.each do |file|
      unless ALLOWED_FILETYPES.include?(file.content_type)
        return redirect_to new_upload_path, alert: 'Disallowed File Type'
      end

      key = "#{Rails.env}/#{@folder}/#{@event}/#{file.original_filename}"
      next if ActiveStorage::Blob.create_and_upload!(
        content_type: file.content_type,
        filename: file.original_filename,
        identify: false,
        io: file,
        key: key
      )

      return redirect_to new_upload_path, alert: 'Upload Failed'
    end
    redirect_to new_upload_path, notice: 'Upload Successful'
  end

  private

  def upload_params
    params.permit(:event, :folder, :uploads)
  end

  ALLOWED_FILETYPES = %w[image/avif image/jpeg image/png image/svg+xml image/webp].freeze
end
