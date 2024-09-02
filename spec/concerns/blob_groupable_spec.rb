# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlobGroupable do
  include ActiveSupport::Testing::TimeHelpers

  it 'returns image filenames in passed folder, grouped by subfolder' do
    ActiveStorage::Blob.create_and_upload!(
      io: Rails.root.join('app/assets/images/fruit_smoothie.avif').open,
      filename: 'fruit_smoothie.avif',
      key: 'time_slots/summer_2023/fruit_smoothie.avif'
    )
    images = TimeSlotsController.new.blobs_by_folder('time_slots')
    expect(images).to eq({ 'time_slots/summer_2023' => [['fruit_smoothie.avif', 1]] })
  end

  it 'does not return images uploaded > 3 months ago' do
  end
end
