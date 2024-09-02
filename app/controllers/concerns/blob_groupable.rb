# frozen_string_literal: true

module BlobGroupable
  extend ActiveSupport::Concern

  included do
    # Returns a hash of 'parent_folder/subfolder' => [[filename, id], [filename, id]]
    # Like { time_slots/summer_2023 => [[fruit_smoothie.avif, 1]] }
    def blobs_by_folder(parent_folder)
      blobs = ActiveStorage::Blob.where('key LIKE ?', "%#{parent_folder}%")
                                 .map { |blob| [blob.key, blob.id] }
      paths = blobs.to_h { |b| [subfolder(b.first), []] }

      blobs.each do |b|
        paths[subfolder(b.first)]
          .push([filename(b.first), b.last])
      end

      paths
    end
  end

  private

  def subfolder(key)
    key.split('/')[0..-2].join('/')
  end

  def filename(key)
    key.split('/').last
  end
end
