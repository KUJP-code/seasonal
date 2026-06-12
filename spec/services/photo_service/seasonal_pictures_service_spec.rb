# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhotoService::SeasonalPicturesService do
  subject(:service) { described_class.new(drive_client:) }

  let(:drive_client) { instance_double(PhotoService::DriveClient) }
  let(:file) do
    {
      name: 'photo.jpg',
      id: 'file-1',
      mimeType: 'image/jpeg',
      thumbnailUrl: 'https://drive.google.com/thumbnail?id=file-1',
      imageUrl: 'https://drive.google.com/uc?id=file-1'
    }
  end

  it 'keeps activities with photos and sorts AM before PM' do
    allow(drive_client).to receive(:pictures_in_folder).with('pm-folder').and_return([file])
    allow(drive_client).to receive(:pictures_in_folder).with('am-folder').and_return([file])
    allow(drive_client).to receive(:pictures_in_folder).with('empty-folder').and_return([])

    result = service.call(
      [
        { date: '2026/07/01 (PM)', name: 'Science', folder_id: 'pm-folder' },
        { date: '2026/07/01 (AM)', name: 'Craft', folder_id: 'am-folder' },
        { date: '2026/07/02 (AM)', name: 'No Photos', folder_id: 'empty-folder' }
      ]
    )

    expect(result.pluck(:name)).to eq(%w[Craft Science])
    expect(result.first[:files]).to eq([file])
  end
end
