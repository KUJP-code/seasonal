# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhotoService::LoginService do
  subject(:service) { described_class.new(sheets_client:) }

  let(:sheets_client) { instance_double(PhotoService::SheetsClient) }

  before do
    allow(sheets_client).to receive(:sheet_data).with('displayVariables').and_return(
      [
        %w[name seasonal party],
        ['expiry', '2026/08/31', '2026/07/31'],
        ['PartyCodes']
      ]
    )
    allow(sheets_client).to receive(:tab_names).and_return(
      %w[displayVariables SSData PartyCodes Ikebukuro]
    )
  end

  it 'logs in party codes with the original response shape' do
    allow(sheets_client).to receive(:sheet_data).with('PartyCodes').and_return(
      [
        ['School', 'Birthday Party'],
        ['Ikebukuro', '12345678']
      ]
    )
    allow(sheets_client).to receive(:sheet_data).with('Ikebukuro').and_return(
      [
        ['Birthday Party'],
        ['party-folder']
      ]
    )

    expect(service.login('12345678')).to eq(
      success: true,
      folder_id: 'party-folder',
      school: 'Ikebukuro',
      expiryDate: '2026/07/31'
    )
  end

  it 'logs in seasonal codes with activities and folder IDs' do
    allow(sheets_client).to receive(:sheet_data).with('SSData').and_return(
      [
        %w[student seasonal-code-1 Ikebukuro]
      ]
    )
    allow(sheets_client).to receive(:sheet_data).with('Ikebukuro').and_return(
      [
        ['2026/07/01 (AM)', '2026/07/01 (PM)'],
        ['2026/07/01 (AM)', '2026/07/01 (PM)'],
        ['Craft', 'Science'],
        ['craft-folder', nil]
      ]
    )

    expect(service.login('seasonal-code-1')).to eq(
      success: true,
      school: 'Ikebukuro',
      activities: [
        { date: '2026/07/01 (AM)', name: 'Craft', folder_id: 'craft-folder' }
      ],
      expiryDate: '2026/08/31'
    )
  end
end
