# frozen_string_literal: true

class ExternalEventCardVariant < ApplicationRecord
  belongs_to :external_event_card, inverse_of: :variants
  has_many :external_event_card_variant_schools,
           dependent: :destroy,
           inverse_of: :external_event_card_variant
  has_many :schools, through: :external_event_card_variant_schools

  has_one_attached :image
  has_one_attached :avif

  validates :event_on, presence: true
  validates :schools, presence: true

  def image_id
    image.blob&.id
  end

  def image_id=(image_id)
    return if image_id.blank?

    self.image = ActiveStorage::Blob.find(image_id)
  end

  def avif_id
    avif.blob&.id
  end

  def avif_id=(avif_id)
    return if avif_id.blank?

    self.avif = ActiveStorage::Blob.find(avif_id)
  end
end
