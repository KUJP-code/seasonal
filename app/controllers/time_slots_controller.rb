# frozen_string_literal: true

# Handles flow of information for Time Slots
class TimeSlotsController < ApplicationController
  def index
    authorize(TimeSlot)
    @events = policy_scope(TimeSlot)
    @event = @events.find { |e| e.id == params[:event].to_i } || @events.first
  end

  def show
    @slot = authorize(TimeSlot.find(params[:id]))
  end

  def new
    authorize(:time_slot)
    if params[:all_schools]
      @events = Event.where(name: params[:event])
                     .includes(:school)
                     .with_attached_image
    else
      @event = Event.find(params[:event])
    end
    @images = slot_blobs
  end

  def edit
    @slot = authorize(TimeSlot.find(params[:id]))
    @images = slot_blobs
  end

  def update
    @slot = authorize(TimeSlot.find(params[:id]))

    if @slot.update(slot_params)
      redirect_to time_slots_path(event: @slot.event_id), notice: t('success', model: '開催日', action: '更新')
    else
      render :edit, status: :unprocessable_entity, alert: t('failure', model: '開催日', action: '更新')
    end
  end

  private

  def slot_params
    params.require(:time_slot).permit(
      :name, :image_id, :start_time, :end_time, :description, :category,
      :closed, :_destroy, :morning, :event_id,
      afternoon_slot_attributes:
      %i[id name image_id start_time end_time description category
         closed _destroy morning event_id],
      options_attributes:
      %i[id _destroy name cost category modifier optionable_type optionable_id]
    )
  end

  def slot_blobs
    blobs = ActiveStorage::Blob.where('key LIKE ?', '%slots%').map { |blob| [blob.key, blob.id] }
    # Create hash of parent folders
    path_hash = blobs.to_h { |b| [b.first.split('/')[0..-2].join('/'), []] }
    # Send the blobs to their parent folder, with only the filename and id left
    blobs.each do |b|
      path_hash[b.first.split('/')[0..-2].join('/')]
        .push([b.first.split('/').last, b.last])
    end

    path_hash
  end
end
