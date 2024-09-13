# frozen_string_literal: true

# Handles direct uploads to ActiveStorage
class UploadsController < ApplicationController
  ALLOWED_FILETYPES = %w[image/avif image/jpeg image/png
                         image/svg+xml image/webp].freeze
  FOLDERS = [%w[Assets assets], %w[Events events],
             %w[Schools schools], %w[Splashes splashes],
             ['Time Slots', 'time_slots']].freeze

  def new
    @folders = FOLDERS
  end

  def create
    params[:uploads].each do |file|
      unless ALLOWED_FILETYPES.include?(file.content_type)
        return redirect_to new_upload_path,
                           alert: "#{file.content_type} can't be uploaded"
      end

      next if upload_file(file, generate_key(file))

      return redirect_to new_upload_path,
                         alert: "Upload failed for #{file.original_filename}"
    end

    redirect_to new_upload_path, notice: 'Upload Successful'
  end

  private

  def upload_params
    params.permit(:subfolder, :folder, :uploads)
  end

  def generate_key(file)
    subfolder = params[:subfolder].downcase.tr(' ', '_')
    filename = "#{file.original_filename}#{Time.zone.now.strftime('%H%M%S')}"
    "#{Rails.env}/#{params[:folder]}/#{subfolder}/#{filename}"
  end

  def upload_file(file, key)
    ActiveStorage::Blob.create_and_upload!(
      content_type: file.content_type,
      filename: file.original_filename,
      identify: false,
      io: file,
      key:
    )
  end
end
