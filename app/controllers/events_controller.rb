# frozen_string_literal: true

# Handles flow of information for events
class EventsController < ApplicationController
  def index
    @events = policy_scope(Event).order(start_date: :desc)
  end

  def show
    @event = Event.find(params[:id])
    @child = params[:child] ? Child.find(params[:child]) : current_user.children.first
    # Check the person accessing is staff or child's parent
    authorize(@child)
    user_specific_info
    @event_slots = @event.time_slots.morning.with_attached_image.includes(afternoon_slot: :options).includes(:options)
    @options = @event.options + @event.slot_options
  end

  def new
    @event = authorize(Event.new)
    new_edit_shared_info
  end

  def edit
    @event = authorize(Event.find(params[:id]))
    new_edit_shared_info
  end

  def create
    authorize(:event)

    if params[:event][:school_id] == 'all'
      results = School.all.map do |school|
        event = school.events.new(event_params)

        # Return an object with the creation result & school name
        { created: event.save, school: event.school.name }
      end

      if results.all? { |r| r[:created] }
        if params[:commit] == 'Create Event'
          redirect_to new_time_slot_path(
                        event: params[:event][:name], 
                        all_schools: true
                      ),
                      notice: "#{params[:event][:name]} created for all schools"
        else
          redirect_to events_path, notice: "Created activities for #{params[:event][:name]} at all schools"
        end
      else
        failed_schools = results.reject { |r| r[:created] }.pluck(:school)
        redirect_to new_event_path,
                    status: :unprocessable_entity,
                    alert: "Events for #{failed_schools.join(', ')} could not be created"
      end
    else
      @event = Event.new(event_params)

      if @event.save
        if params[:commit] == 'Create Event'
          redirect_to new_time_slot_path(event: @event.id), 
                      notice: "Created #{@event.name} at #{@event.school.name}"
        else
          redirect_to events_path, notice: "Created activities for #{@event.name} ay #{@event.school.name}"
        end
      else
        render :new,
               status: :unprocessable_entity,
               alert: "#{@event.name} could not be created at #{@event.school.name}"
      end
    end
  end

  def update
    authorize(:event)

    if params[:event][:school_id] == 'all' || params[:event][:school_id].nil?
      results = School.all.map do |school|
        event = school.events.find_by(name: params[:event][:name])
        params[:event][:school_id] = event.school_id

        { updated: event.update(event_params), school: school.name }
      end

      if results.all? { |r| r[:updated] }
        redirect_to events_path, notice: "All events with name: #{params[:event][:name]} updated"
      else
        failed_schools = results.reject { |r| r[:updated] }.pluck(:school)
        redirect_to new_event_path,
                    status: :unprocessable_entity,
                    alert: "Events for #{failed_schools.join(', ')} could not be created"
      end
    else
      @event = Event.find(params[:id])

      if @event.update(event_params)
        redirect_to events_path, notice: "Updated #{@event.name} at #{@event.school.name}"
      else
        render :edit,
               status: :unprocessable_entity,
               alert: "Failed to update #{@event.name} at #{@event.school.name}"
      end
    end
  end

  private

  def event_params
    params.require(:event).permit(
      :name, :description, :start_date, :image_id, :end_date, :school_id,
      :member_prices_id, :goal, :non_member_prices_id,
      time_slots_attributes:
        %i[id name start_time end_time category event_id morning
           morning_slot_id image_id _destroy],
      options_attributes:
        %i[id name cost category modifier optionable_type optionable_id
           _destroy]
    )
  end

  def new_edit_shared_info
    @images = ActiveStorage::Blob.where('key LIKE ?', '%events%').map { |blob| [blob.key, blob.id] }
    @prices = PriceList.order(:name)
    @schools = [%w[All all]] + School.order(:id).map { |school| [school.name, school.id] }
  end

  def user_specific_info
    @member_prices = @event.member_prices
    @non_member_prices = @event.non_member_prices
    @children = @child.siblings.to_a.unshift(@child)
    @all_invoices = @child.invoices.where(event: @event).includes(:registrations)

    return unless @all_invoices.empty? || @all_invoices.all?(&:in_ss)

    # I'm doing this in 2 lines because the view code wants an AR relation
    Invoice.create(child: @child, event: @event, total_cost: 0)
    @all_invoices = @child.invoices.where(event: @event).reload
  end
end
