# frozen_string_literal: true

# Handles flow of information for events
class EventsController < ApplicationController
  def index
    @events = policy_scope(Event).with_attached_image
                                 .with_attached_avif
                                 .page(params[:page])
  end

  def show
    @event = Event.find(params[:id])
    @child = params[:child] ? Child.find(params[:child]) : current_user.children.first
    # Check the person accessing is staff or child's parent
    authorize(@child)
    user_specific_info
    @event_slots = @event.time_slots.morning
                         .with_attached_image
                         .with_attached_avif
                         .includes(
                           :options,
                           afternoon_slot: %i[options]
                         )
    @options = @event.options + @event.slot_options
  end

  def new
    @event = authorize(Event.new)
    form_info
  end

  def edit
    @event = authorize(Event.find(params[:id]))
    form_info
  end

  def create
    authorize(:event)

    if params[:event][:school_id] == 'all'
      results = School.all.map do |school|
        event = school.events.new(event_params)

        # Return an object with the creation result & school name
        { created: event.save!, school: event.school.name }
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
          redirect_to time_slots_path(event: @event, school: @event.school_id),
                      notice: "Created activities for #{@event.name} at #{@event.school.name}"
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
        redirect_to time_slots_path(event: @event.id, school: @event.school_id),
                    notice: "Updated #{@event.name} at #{@event.school.name}"
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
      :name, :start_date, :image_id, :end_date, :school_id,
      :member_prices_id, :goal, :non_member_prices_id, :avif_id,
      time_slots_attributes:
        %i[id name start_time end_time category event_id morning snack
           morning_slot_id image_id int_modifier ext_modifier _destroy],
      options_attributes:
        %i[id name cost category modifier optionable_type optionable_id
           _destroy]
    )
  end

  def form_info
    @images = ActiveStorage::Blob.where('key LIKE ?', '%events%').map { |blob| [blob.key, blob.id] }
    @prices = PriceList.order(:name)
    @schools = [%w[All all]] + School.order(:id).map { |school| [school.name, school.id] }
  end

  def user_specific_info
    @member_prices = @event.member_prices
    @non_member_prices = @event.non_member_prices
    @children = @child.siblings.to_a.unshift(@child)
    @all_invoices = @child.invoices
                          .where(event: @event)
                          .includes(:registrations)
                          .to_a

    return unless @all_invoices.empty? || @all_invoices.all?(&:in_ss)

    temp_invoice = Invoice.new(child: @child, event: @event, total_cost: 0)
    @all_invoices.push(temp_invoice)
  end
end
