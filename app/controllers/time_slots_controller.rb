# frozen_string_literal: true

# Handles flow of information for Time Slots
class TimeSlotsController < ApplicationController
  def index
    authorize(TimeSlot)
    @events = policy_scope(TimeSlot).order(:school_id).page(params[:page]).per(1)
  end

  def show
    @slot = authorize(TimeSlot.find(params[:id]))
  end

  def edit
    @slot = authorize(TimeSlot.find(params[:id]))
  end

  def update
    @slot = authorize(TimeSlot.find(params[:id]))

    if @slot.update(slot_params)
      redirect_to time_slot_path(@slot), notice: t('success', model: 'Time Slot', action: '更新')
    else
      render :edit, status: :unprocessable_entity, alert: t('failure', model: 'Time Slot', action: '更新')
    end
  end

  private

  def slot_params
    params.require(:time_slot).permit(:name, :image, :start_time, :end_time, :description, :category, :closed,
                                      :morning, :event_id)
  end
end
