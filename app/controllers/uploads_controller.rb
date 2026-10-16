# frozen_string_literal: true

# Handles asset uploads through the application to ActiveStorage.
class UploadsController < ApplicationController
  ALLOWED_FILETYPES = %w[image/avif image/jpeg image/png
                         image/svg+xml image/webp].freeze
  FOLDERS = [%w[Assets assets], %w[Events events],
             %w[Schools schools], %w[Splashes splashes],
             ['Time Slots', 'time_slots']].freeze
  # Leave room for multipart fields below Nginx's 10 MB request limit.
  MAX_FILE_SIZE = 9.megabytes

  after_action :verify_authorized

  def new
    authorize :upload
    @folders = FOLDERS
  end

  def create
    authorize :upload
    @uploaded = []
    @errors = []
    files = Array(upload_params[:uploads]).compact_blank
    error = request_error(files)
    if error
      @errors << { message: error, retryable: false }
    else
      files.each { |file| process_file(file) }
    end

    render_upload_result(files.size)
  end

  private

  def render_upload_result(total)
    respond_to do |format|
      format.json do
        render json: { uploaded: @uploaded, errors: @errors },
               status: @errors.empty? ? :ok : :unprocessable_entity
      end
      format.html { redirect_upload_result(total) }
    end
  end

  def redirect_upload_result(total)
    summary = "Uploaded #{@uploaded.size} of #{total} files."
    if @errors.empty?
      redirect_to new_upload_path, notice: summary, status: :see_other
    else
      details = @errors.map do |failure|
        [failure[:filename], failure[:message]].compact.join(': ')
      end
      redirect_to new_upload_path, alert: "#{summary} #{details.join(' ')}", status: :see_other
    end
  end

  def request_error(files)
    return 'Select at least one image.' if files.empty?

    valid_folder = FOLDERS.any? { |_label, folder| folder == upload_params[:folder] }
    return 'Select a valid folder.' unless valid_folder
    return 'Subfolder cannot contain ..' if upload_params[:subfolder].to_s.include?('..')

    identifier = upload_params[:upload_id]
    return if identifier.blank? || identifier.match?(/\A[\da-f-]{36}\z/)

    'Invalid upload identifier. Select the files again.'
  end

  def process_file(file)
    error = file_error(file)
    if error
      @errors << { filename: file.original_filename, message: error, retryable: false }
      return
    end

    blob = upload_file(file, generate_key(file))
    @uploaded << { filename: file.original_filename, id: blob.id }
  rescue StandardError => e
    Rails.logger.error("Asset upload failed: #{e.class}: #{e.message}")
    @errors << { filename: file.original_filename,
                 message: 'Could not save this image. Retry the upload.', retryable: true }
  end

  def file_error(file)
    unless ALLOWED_FILETYPES.include?(file.content_type)
      return 'Unsupported image type. Use PNG, JPEG, AVIF, WebP, or SVG.'
    end
    if file.size > MAX_FILE_SIZE
      return 'Image exceeds 9 MB. Export a smaller image and select it again.'
    end

    'This image is empty.' unless file.size.positive?
  end

  def upload_params
    @upload_params ||= params.permit(:subfolder, :folder, :upload_id, uploads: [])
  end

  def generate_key(file)
    subfolder = upload_params[:subfolder].to_s.downcase.tr(' ', '_')
    identifier = upload_params[:upload_id].presence || SecureRandom.uuid
    filename = "#{ActiveStorage::Filename.new(file.original_filename).sanitized}#{identifier}"
    "#{Rails.env}/#{upload_params[:folder]}/#{subfolder}/#{filename}"
  end

  def upload_file(file, key)
    blob = ActiveStorage::Blob.build_after_unfurling(
      content_type: file.content_type,
      filename: file.original_filename,
      identify: false,
      io: file,
      key:
    )
    existing = ActiveStorage::Blob.find_by(key:)
    return matching_upload(existing, blob) if existing

    # Roll back the record if storage fails, so missing files never appear as uploaded assets.
    ActiveStorage::Blob.transaction(requires_new: true) do
      blob.save!
      blob.upload_without_unfurling(file)
    end
    blob
  rescue ActiveRecord::RecordNotUnique
    matching_upload(ActiveStorage::Blob.find_by!(key:), blob)
  end

  def matching_upload(existing, blob)
    return existing if existing.checksum == blob.checksum && existing.byte_size == blob.byte_size

    raise ArgumentError, 'Upload identifier already belongs to another image'
  end
end
