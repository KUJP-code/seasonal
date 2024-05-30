# frozen_string_literal: true

module BlobGroupable
  extend ActiveSupport::Concern

  included do
    def blobs_by_folder(parent_folder)
      blobs = ActiveStorage::Blob.where('key LIKE ?', "%#{parent_folder}%")
                                 .map { |blob| [blob.key, blob.id] }
      paths = blobs.to_h { |b| [slice_path(b.first), []] }

      blobs.each do |b|
        paths[slice_path(b.first)]
          .push([slice_filename(b.first), b.last])
      end

      paths
    end
  end

  private

  def slice_path(key)
    key.split('/')[0..-2].join('/')
  end

  def slice_filename(key)
    key.split('/').last
  end
end
