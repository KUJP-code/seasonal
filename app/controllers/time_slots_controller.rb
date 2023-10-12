# frozen_string_literal: true

# Handles flow of information for Time Slots
class TimeSlotsController < ApplicationController
  def index
    index_schools
    index_events
    @slots = index_slots(@event) unless @event.nil?
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
                     .with_attached_avif
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
    return bulk_create_aft_slots if params[:time_slot][:apply_all] == '1'

    if @slot.update(slot_params)
      redirect_to time_slots_path(
        event: @slot.event_id,
        school: @slot.school.id
      ), notice: "Updated #{@slot.name}"
    else
      render :edit, status: :unprocessable_entity,
                    alert: "#{@slot.name} couldn't be updated"
    end
  end

  private

  def slot_params
    params.require(:time_slot).permit(
      :id, :name, :start_time, :end_time, :category, :apply_all, :ext_modifier,
      :avif_id, :closed, :_destroy, :morning, :event_id, :image_id,
      :int_modifier, :snack,
      afternoon_slot_attributes:
      %i[id name image_id start_time end_time category snack
         closed _destroy morning event_id ext_modifier int_modifier],
      options_attributes:
      %i[id _destroy name cost category modifier optionable_type optionable_id]
    )
  end

  def blobs_by_folder(blobs)
    paths = blobs.to_h { |b| [slice_path(b.first), []] }

    blobs.each do |b|
      paths[slice_path(b.first)]
        .push([slice_filename(b.first), b.last])
    end

    paths
  end

  def bulk_create_aft_slots
    same_name_slots = @slot.same_name_slots

    same_name_slots.each do |s|
      afternoon_attr = slot_params[:afternoon_slot_attributes]
      afternoon_attr[:event_id] = s.event_id
      s.create_afternoon_slot(afternoon_attr)
    end

    redirect_to time_slots_path,
                notice: "All #{@slot.name} activities created"
  end

  def find_blobs
    ActiveStorage::Blob.where('key LIKE ?', '%slots%')
                       .map { |blob| [blob.key, blob.id] }
  end

  def index_schools
    @schools = policy_scope(School)
    @school = @schools.find { |s| s.id == params[:school].to_i } || @schools.last
  end

  def index_events
    @events = @school.events.order(start_date: :asc)
    @event = index_active_event
  end

  def index_active_event
    return @events.find { |e| e.id == params[:event].to_i } if params[:event]
    return @school.next_event if @school.next_event

    @events.last
  end

  def index_slots(event)
    event.time_slots.morning
         .or(@event.time_slots.special)
         .includes(:afternoon_slot)
         .with_attached_image
         .with_attached_avif
         .order(:start_time)
  end

  def slice_filename(key)
    key.split('/').last
  end

  def slice_path(key)
    key.split('/')[0..-2].join('/')
  end

  def slot_blobs
    blobs = find_blobs
    blobs_by_folder(blobs)
  end
end
