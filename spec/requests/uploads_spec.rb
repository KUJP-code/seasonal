# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Asset uploads' do
  let(:headers) { { 'ACCEPT' => 'application/json' } }

  before { sign_in create(:admin) }

  def image_upload(name = 'photo_service_mobile.png', content_type = 'image/png')
    Rack::Test::UploadedFile.new(Rails.root.join('app/assets/images', name), content_type)
  end

  def upload_params(files, **extra)
    { uploads: files, folder: 'time_slots', subfolder: 'Winter 2026' }.merge(extra)
  end

  it 'renders the upload queue with the supported image types and size limit' do
    get new_upload_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('asset-upload', '9 MB', 'Retry failed uploads')
  end

  it 'stores an image in the selected folder and confirms it only after storage succeeds' do
    file = image_upload
    post(uploads_path, params: upload_params([file]), headers:)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['errors']).to be_empty
    blob = ActiveStorage::Blob.find(response.parsed_body['uploaded'].sole['id'])
    expect(blob.key).to start_with('test/time_slots/winter_2026/photo_service_mobile.png')
    expect(blob.download).to eq(File.binread(file.path))
  end

  it 'handles an omitted subfolder' do
    post(uploads_path, params: upload_params([image_upload], subfolder: nil), headers:)

    expect(response).to have_http_status(:ok)
  end

  it 'reports an empty selection' do
    post(uploads_path, params: upload_params([]), headers:)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body['errors'].sole['message']).to include('Select at least one image')
  end

  it 'rejects invalid destinations without creating records' do
    expect do
      post(uploads_path, params: upload_params([image_upload], folder: 'unknown'), headers:)
    end.not_to change(ActiveStorage::Blob, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body['errors'].sole['message']).to include('valid folder')
  end

  it 'reports unsupported types without discarding other successful files' do
    invalid = image_upload('favicon.svg', 'text/plain')
    post(uploads_path, params: upload_params([invalid, image_upload]), headers:)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body['uploaded'].size).to eq(1)
    expect(response.parsed_body['errors'].sole).to include(
      'filename' => 'favicon.svg', 'retryable' => false
    )
  end

  it 'rejects images over the per-file limit' do
    stub_const('UploadsController::MAX_FILE_SIZE', 1.kilobyte)

    expect do
      post(uploads_path, params: upload_params([image_upload]), headers:)
    end.not_to change(ActiveStorage::Blob, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body['errors'].sole['message']).to include('exceeds 9 MB')
  end

  it 'reports storage errors and rolls back failed records while continuing the batch' do
    service = ActiveStorage::Blob.service
    allow(service).to receive(:upload).and_wrap_original do |original, key, *args, **kwargs|
      raise IOError, 'Storage unavailable' if key.include?('favicon.svg')

      original.call(key, *args, **kwargs)
    end

    files = [image_upload('favicon.svg', 'image/svg+xml'), image_upload]
    post(uploads_path, params: upload_params(files), headers:)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body['errors'].sole).to include(
      'filename' => 'favicon.svg', 'retryable' => true
    )
    expect(response.parsed_body['uploaded'].sole['filename']).to eq('photo_service_mobile.png')
    expect(ActiveStorage::Blob.count).to eq(1)
    expect(ActiveStorage::Blob.last.filename.to_s).to eq('photo_service_mobile.png')
  end

  it 'does not duplicate a completed upload when the browser retries the same identifier' do
    identifier = SecureRandom.uuid
    post(uploads_path, params: upload_params([image_upload], upload_id: identifier), headers:)
    original_id = response.parsed_body['uploaded'].sole['id']

    expect do
      post(uploads_path, params: upload_params([image_upload], upload_id: identifier), headers:)
    end.not_to change(ActiveStorage::Blob, :count)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['uploaded'].sole['id']).to eq(original_id)
  end

  it 'allows a failed upload to succeed when retried with the same identifier' do
    identifier = SecureRandom.uuid
    service = ActiveStorage::Blob.service
    allow(service).to receive(:upload).and_raise(IOError, 'Storage unavailable')
    post(uploads_path, params: upload_params([image_upload], upload_id: identifier), headers:)
    expect(response).to have_http_status(:unprocessable_entity)
    expect(ActiveStorage::Blob.count).to eq(0)

    allow(service).to receive(:upload).and_call_original
    post(uploads_path, params: upload_params([image_upload], upload_id: identifier), headers:)

    expect(response).to have_http_status(:ok)
    expect(ActiveStorage::Blob.count).to eq(1)
    expect(ActiveStorage::Blob.last.service.exist?(ActiveStorage::Blob.last.key)).to be true
  end

  it 'gives HTML form submissions a visible summary when only some files succeeded' do
    invalid = image_upload('favicon.svg', 'text/plain')
    post uploads_path, params: upload_params([image_upload, invalid])

    expect(response).to redirect_to(new_upload_path)
    expect(flash[:alert]).to include('Uploaded 1 of 2 files.', 'favicon.svg',
                                     'Unsupported image type')
  end

  it 'restricts asset uploads to admins' do
    sign_out :user
    sign_in create(:customer)

    get new_upload_path
    expect(response).to redirect_to(root_path(locale: I18n.locale))

    expect do
      post(uploads_path, params: upload_params([image_upload]), headers:)
    end.not_to change(ActiveStorage::Blob, :count)
    expect(response).to redirect_to(root_path(locale: I18n.locale))
  end
end
