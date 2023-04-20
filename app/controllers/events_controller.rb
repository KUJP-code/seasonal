# frozen_string_literal: true

# Handles flow of information for events
class EventsController < ApplicationController
  def index
    @events = index_for_role
  end

  def show
    @event = Event.find(params[:id])
    @child = Child.find(params[:child])
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
    if params[:event][:school_id] == 'all'
      School.all.each do |school|
        school.events.create(event_params)
      end
      redirect_to events_path
    else
      @event = Event.new(event_params)

      if @event.save
        flash_success
        redirect_to events_path
      else
        flash_failure
        render :new, status: :unprocessable_entity
      end
    end
  end

  def update
    @event = Event.find(params[:id])

    if @event.update(event_params)
      flash_success
      redirect_to events_path
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

  def event_params
    params.require(:event).permit(:id, :name, :description, :start_date, :image,
                                  :end_date, :school_id, :member_prices_id, :goal, :non_member_prices_id,
                                  time_slots_attributes:
                                  %i[id name start_time end_time description
                                     category closed event_id morning morning_slot_id image _destroy])
  end

  def flash_failure
    flash.now[:alert] = t('.failure')
  end

  def flash_success
    flash.now[:notice] = t('.success')
  end

  def user_specific_info
    @member_prices = @event.member_prices
    @non_member_prices = @event.non_member_prices
    @children = @child.siblings.to_a.unshift(@child)
    @all_invoices = @child.invoices.where(event: @event).includes(:registrations)

    return unless @all_invoices.empty? || @all_invoices.all?(&:in_ss)

    # I'm doing this in 2 lines because the view code wants an AR relation
    Invoice.create(child: @child, event: @event, total_cost: 0).calc_cost
    @all_invoices = @child.invoices.where(event: @event).reload
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
      current_user.children_events
    end
  end
end
