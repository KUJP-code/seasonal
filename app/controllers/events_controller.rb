# frozen_string_literal: true

class EventsController < ApplicationController
  include BlobGroupable

  before_action :set_form_data, only: %i[new edit create update]
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize Event
    @events = policy_scope(Event).includes(
      :school,
      image_attachment: %i[blob],
      avif_attachment: %i[blob]
    ).order(start_date: :desc, school_id: :desc).page(params[:page])
  end

  def show
    @event = authorize Event.find(params[:id])
    return old_event_redirect if current_user.customer? && Time.zone.today > @event.end_date

    @child = authorize params[:child] ? Child.find(params[:child]) : current_user.children.first
    return orphan_redirect if @child.parent_id.nil?

    user_specific_info
    @event_slots = @event.time_slots.morning
                         .with_attached_image
                         .with_attached_avif
                         .includes(
                           :options,
                           afternoon_slot: %i[options]
                         ).order(start_time: :asc)
    @options = @event.options + @event.slot_options
  end

  def new
    @event = authorize Event.new
  end

  def edit
    @event = authorize Event.find(params[:id])
  end

  def create
    authorize Event

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
          redirect_to events_path,
                      notice: "Created activities for #{params[:event][:name]} at all schools"
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
    authorize Event

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
      :name, :start_date, :image_id, :end_date, :school_id, :released, :early_bird_date,
      :member_prices_id, :goal, :non_member_prices_id, :avif_id, :early_bird_discount,
      time_slots_attributes:
        %i[id name start_time end_time category event_id morning snack avif_id close_at
           morning_slot_id image_id int_modifier ext_modifier kindy_modifier ele_modifier _destroy],
      options_attributes:
        %i[id name cost category modifier optionable_type optionable_id
           _destroy]
    )
  end

  def set_form_data
    @images = blobs_by_folder('events')
    @prices = PriceList.order(:name)
    @schools = [%w[All all]] + School.order(:id).map { |school| [school.name, school.id] }
  end

  def old_event_redirect
    redirect_to root_path,
                alert: "下記カレンダーよりご希望のアクティビティをクリックし、選択してください。\n<注意>すでに終了しているアクティビティは選択をしないようご注意ください。"
  end

  def orphan_redirect
    redirect_to @child, alert: 'お子様がアクティビティに参加するには、保護者の同伴が必要です。'
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
