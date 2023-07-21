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
    if params[:event] == 'all'
      @events = authorize(Event.where(id: params[:event]))
    else
      @event = authorize(Event.find(params[:event]))
    end
    @images = ActiveStorage::Blob.where('key LIKE ?', '%slots%').map { |blob| [blob.key, blob.id] }
  end

  def edit
    @slot = authorize(TimeSlot.find(params[:id]))
  end

  def create
    @event = authorize(Event.find(params[:event]))

    if @event.save
      redirect_to events_path, notice: t('success', model: '開催日', action: '追加')
    else
      render :new, status: :unprocessable_entity, alert: t('failure', model: '開催日', action: '追加')
    end
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
      :name, :image, :start_time, :end_time, :description, :category, :closed,
      :morning, :event_id
    )
  end
end
