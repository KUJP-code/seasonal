# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Photo service API' do
  describe 'POST /api/login' do
    it 'returns the existing party login payload shape' do
      login_service = instance_double(
        PhotoService::LoginService,
        login: {
          success: true,
          folder_id: 'drive-folder-1',
          school: 'Ikebukuro',
          expiryDate: '2026/07/31'
        }
      )
      allow(PhotoService::LoginService).to receive(:new).and_return(login_service)

      post '/api/login', params: { code: '12345678' }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(
        'success' => true,
        'folder_id' => 'drive-folder-1',
        'school' => 'Ikebukuro',
        'expiryDate' => '2026/07/31'
      )
      expect(login_service).to have_received(:login).with('12345678')
    end

    it 'returns unauthorized for bad codes' do
      login_service = instance_double(
        PhotoService::LoginService,
        login: { success: false, message: 'Incorrect Login Code' }
      )
      allow(PhotoService::LoginService).to receive(:new).and_return(login_service)

      post '/api/login', params: { code: 'bad-code' }, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body).to eq(
        'success' => false,
        'message' => 'Incorrect Login Code'
      )
    end
  end

  describe 'GET /api/pictures' do
    it 'returns the existing files payload shape' do
      drive_client = instance_double(
        PhotoService::DriveClient,
        pictures_in_folder: [
          {
            name: 'photo.jpg',
            id: 'file-1',
            mimeType: 'image/jpeg',
            thumbnailUrl: 'https://drive.google.com/thumbnail?id=file-1',
            imageUrl: 'https://drive.google.com/uc?id=file-1'
          }
        ]
      )
      allow(PhotoService::DriveClient).to receive(:new).and_return(drive_client)

      get '/api/pictures', params: { folder_id: 'folder-1' }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(
        'files' => [
          {
            'name' => 'photo.jpg',
            'id' => 'file-1',
            'mimeType' => 'image/jpeg',
            'thumbnailUrl' => 'https://drive.google.com/thumbnail?id=file-1',
            'imageUrl' => 'https://drive.google.com/uc?id=file-1'
          }
        ]
      )
      expect(drive_client).to have_received(:pictures_in_folder).with('folder-1')
    end
  end

  describe 'POST /api/seasonal-pictures' do
    it 'returns the existing seasonal pictures payload shape' do
      service = instance_double(
        PhotoService::SeasonalPicturesService,
        call: [
          {
            date: '2026/07/01 (AM)',
            name: 'Activity',
            folder_id: 'folder-1',
            files: [
              {
                name: 'photo.jpg',
                id: 'file-1',
                mimeType: 'image/jpeg',
                thumbnailUrl: 'https://drive.google.com/thumbnail?id=file-1',
                imageUrl: 'https://drive.google.com/uc?id=file-1'
              }
            ]
          }
        ]
      )
      allow(PhotoService::SeasonalPicturesService).to receive(:new).and_return(service)

      post '/api/seasonal-pictures',
           params: {
             activities: [
               { date: '2026/07/01 (AM)', name: 'Activity', folder_id: 'folder-1' }
             ]
           },
           as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(
        [
          {
            'date' => '2026/07/01 (AM)',
            'name' => 'Activity',
            'folder_id' => 'folder-1',
            'files' => [
              {
                'name' => 'photo.jpg',
                'id' => 'file-1',
                'mimeType' => 'image/jpeg',
                'thumbnailUrl' => 'https://drive.google.com/thumbnail?id=file-1',
                'imageUrl' => 'https://drive.google.com/uc?id=file-1'
              }
            ]
          }
        ]
      )
    end
  end
end
