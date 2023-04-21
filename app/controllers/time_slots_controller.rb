# frozen_string_literal: true

class TimeSlotsController < ApplicationController
  def show
    @slot = TimeSlot.find(params[:id])
  end

  def index
    @events = index_for_role
  end

  def edit
    @slot = TimeSlot.find(params[:id])
  end

  def update
    @slot = TimeSlot.find(params[:id])

    if @slot.update(slot_params)
      redirect_to time_slot_path(@slot), notice: t('update_success')
    else
      render :edit, status: :unprocessable_entity, notice: t('update_fail')
    end
  end

  private

  def index_for_role
    case current_user.role
    when 'admin'
      Event.all.order(start_date: :asc).includes(:time_slots)
    when 'area_manager'
      current_user.area_events.includes(:time_slots)
    when 'school_manager'
      current_user.school_events.includes(:time_slots)
    else
      current_user.children_events.includes(:time_slots)
    end
  end

  def slot_params
    params.require(:time_slot).permit(:name, :image, :start_time, :end_time, :description, :category, :closed, :morning, :event_id)
  end
end
