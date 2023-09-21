# frozen_string_literal: true

# Handles flow of information for Time Slots
class TimeSlotsController < ApplicationController
  def index
    @events = policy_scope(TimeSlot).order(:school_id)
    @event = @events.find { |e| e.id == params[:event].to_i } || @events.last
    @slots = @event.time_slots.morning
                   .or(@event.time_slots.special)
                   .includes(:afternoon_slot)
                   .with_attached_image
                   .order(:start_time)
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

    if params[:time_slot][:apply_all] == '1'
      same_name_slots = TimeSlot.where(name: @slot.name,
                                       morning: @slot.morning,
                                       category: @slot.category)

      results = same_name_slots.map do |s|
        afternoon_attr = slot_params[:afternoon_slot_attributes]
        afternoon_attr[:event_id] = s.event_id
        { updated: s.create_afternoon_slot(afternoon_attr).persisted?, school: s.name }
      end

      if results.all? { |r| r[:updated] }
        redirect_to time_slots_path, notice: "All #{@slot.name} activities updated"
      else
        failed_aft_slots = results.reject { |r| r[:created] }.pluck(:school)
        render :edit,
               status: :unprocessable_entity,
               alert: "Afternoon activities for #{failed_aft_slots.join(', ')} could not be created"
      end
    elsif @slot.update(slot_params)
      redirect_to time_slots_path(event: @slot.event_id), notice: "Updated #{@slot.name} at #{@slot.school.name}"
    else
      render :edit, status: :unprocessable_entity, alert: "#{@slot.name} at #{@slot.school.name} couldn't be updated"
    end
  end

  private

  def slot_params
    params.require(:time_slot).permit(
      :id, :name, :start_time, :end_time, :category, :apply_all, :ext_modifier,
      :closed, :_destroy, :morning, :event_id, :image_id, :int_modifier, :snack,
      afternoon_slot_attributes:
      %i[id name image_id start_time end_time category snack
         closed _destroy morning event_id ext_modifier int_modifier],
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
