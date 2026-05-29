# frozen_string_literal: true

class ExternalEventCardsController < ApplicationController
  include BlobFindable

  before_action :set_form_data, only: %i[new edit create update]
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize ExternalEventCard
    @external_event_cards = policy_scope(ExternalEventCard)
                            .includes(variants: :schools)
                            .order(starts_on: :desc, title: :asc)
                            .page(params[:page])
  end

  def new
    @external_event_card = authorize ExternalEventCard.new(
      starts_on: Time.zone.today,
      ends_on: Time.zone.today,
      variants: [ExternalEventCardVariant.new]
    )
  end

  def edit
    @external_event_card = authorize external_event_card
    @external_event_card.variants.build if @external_event_card.variants.empty?
  end

  def create
    @external_event_card = authorize ExternalEventCard.new(external_event_card_params)

    if @external_event_card.save
      redirect_to external_event_cards_path,
                  notice: "#{@external_event_card.title} created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @external_event_card = authorize external_event_card

    if @external_event_card.update(external_event_card_params)
      redirect_to external_event_cards_path,
                  notice: "#{@external_event_card.title} updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @external_event_card = authorize external_event_card
    @external_event_card.destroy

    redirect_to external_event_cards_path,
                notice: "#{@external_event_card.title} deleted"
  end

  private

  def external_event_card
    ExternalEventCard.includes(variants: [
                                 :schools,
                                 { image_attachment: :blob, avif_attachment: :blob }
                               ]).find(params[:id])
  end

  def external_event_card_params
    params.require(:external_event_card).permit(
      :title, :url, :note, :starts_on, :ends_on, :active,
      variants_attributes: [
        :id, :event_on, :image_id, :avif_id, :_destroy,
        { school_ids: [] }
      ]
    )
  end

  def set_form_data
    card = ExternalEventCard.includes(variants: [
                                        { image_attachment: :blob },
                                        { avif_attachment: :blob }
                                      ]).find_by(id: params[:id])
    @images = blobs_by_folder('events',
                              attached_blobs: attached_blobs_for(card&.variants))
    @schools = School.real.order(:id)
  end
end
