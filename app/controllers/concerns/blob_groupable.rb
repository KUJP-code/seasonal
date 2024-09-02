# frozen_string_literal: true

module BlobGroupable
  extend ActiveSupport::Concern

  included do
    # Returns a hash of 'parent_folder/subfolder' => [[filename, id], [filename, id]]
    # Like { time_slots/summer_2023 => [[fruit_smoothie.avif, 1]] }
    # So they can be grouped in a select input
    def blobs_by_folder(parent_folder)
      blobs = ActiveStorage::Blob.where('key LIKE ?', "%#{parent_folder}%")
                                 .where(created_at: 2.months.ago..Time.zone.now)
                                 .order(created_at: :desc).pluck(:key, :id)
      group_by_path(blobs)
    end
  end

  private

  def group_by_path(blobs)
    paths = blobs.to_h { |key, _id| [path(key), []] }

    blobs.each do |key, id|
      paths[path(key)].push([filename(key), id])
    end

    paths
  end

  def path(key)
    key.split('/')[0..-2].join('/')
  end

  def filename(key)
    key.split('/').last
  end
end
