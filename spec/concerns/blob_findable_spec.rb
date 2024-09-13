# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlobFindable do
  include ActiveSupport::Testing::TimeHelpers

  [EventsController, TimeSlotsController].each do |controller|
    context "when used in #{controller}" do
      it 'returns image filenames in passed folder, grouped by subfolder' do
        parent_folder = controller.class.name.underscore.tr('controller', '')
        blob = ActiveStorage::Blob.create_and_upload!(
          io: Rails.root.join('app/assets/images/fruit_smoothie.avif').open,
          filename: 'fruit_smoothie.avif',
          key: "#{parent_folder}/summer_2023/fruit_smoothie.avif"
        )
        images = controller.new.send(:blobs_by_folder, parent_folder)
        expect(images).to eq({ "#{parent_folder}/summer_2023" =>
                               [['fruit_smoothie.avif', blob.id]] })
      end

      it 'does not return images uploaded > 2 months ago' do
        parent_folder = controller.class.name.underscore.tr('controller', '')
        ActiveStorage::Blob.create_and_upload!(
          io: Rails.root.join('app/assets/images/fruit_smoothie.avif').open,
          filename: 'fruit_smoothie.avif',
          key: "#{parent_folder}/summer_2023/fruit_smoothie.avif"
        )
        travel_to(2.months.from_now + 1.day)
        images = controller.new.send(:blobs_by_folder, parent_folder)
        expect(images).to be_blank
      end
    end
  end
end
