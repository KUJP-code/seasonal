# frozen_string_literal: true

# Handles flow of information for events
class EventsController < ApplicationController
  def index
    @events = index_for_role
  end

  def show
    @event = Event.find(params[:id])
    user_specific_info
    @event_slots = @event.time_slots.morning.with_attached_image.includes(afternoon_slot: :options).includes(:options)
    @options = @event.options + @event.slot_options
  end

  def new
    @event = Event.new
  end

  def edit
    @event = Event.find(params[:id])
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      flash_success
      redirect_to event_path(@event)
    else
      flash_failure
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @event = Event.find(params[:id])

    if @event.update(event_params)
      flash_success
      redirect_to event_path(@event)
    else
      flash_failure
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event = Event.find(params[:id])
    return flash.now[:alert] = t('.event_attended') unless @event.children.empty?

    if @event.destroy
      flash_success
      redirect_to events_path
    else
      flash_failure
    end
  end

  private

  def price_lists
    @member_prices = @event.member_prices
    @non_member_prices = @event.non_member_prices
  end

  def event_params
    params.require(:event).permit(:id, :name, :description, :start_date,
                                  :end_date, :school_id, time_slots_attributes:
                                  %i[id name start_time end_time description
                                     max_attendees registration_deadline event_id _destroy])
  end

  def flash_failure
    flash.now[:alert] = t('.failure')
  end

  def flash_success
    flash.now[:notice] = t('.success')
  end

  def user_specific_info
    price_lists
    @invoice = Invoice.find_by(event: @event, parent: current_user)
    @children = current_user.children.includes(:time_slots, :registrations)
  end

  def index_for_role
    case current_user.role
    when 'admin'
      Event.all.order(start_date: :asc).with_attached_image
    when 'area_manager'
      current_user.area_events.with_attached_image
    when 'school_manager'
      current_user.school_events.with_attached_image
    else
      current_user.school.events.with_attached_image
    end
  end
end
