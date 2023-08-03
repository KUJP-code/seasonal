# frozen_string_literal: true

# Handles flow of information for events
class EventsController < ApplicationController
  def index
    @events = policy_scope(Event).order(:start_date)
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
    @images = ActiveStorage::Blob.where('key LIKE ?', '%events%').map { |blob| [blob.key, blob.id] }
    @prices = PriceList.order(:name)
    @schools = [%w[All all]] + School.order(:id).map { |school| [school.name, school.id] }
  end

  def edit
    @event = authorize(Event.find(params[:id]))
    @images = ActiveStorage::Blob.where('key LIKE ?', '%events%').map { |blob| [blob.key, blob.id] }
    @prices = PriceList.order(:name)
    @schools = [%w[All all]] + School.order(:id).map { |school| [school.name, school.id] }
  end

  def create
    authorize(:event)

    if params[:event][:school_id] == 'all'
      School.all.each do |school|
        school.events.create(event_params)
      end
      redirect_to new_time_slot_path(event: 'all'), notice: t('success', model: 'イベント', action: '追加') if params[:commit] == 'Update Event'
      redirect_to events_path, notice: t('success', model: 'イベント', action: '追加') if params[:commit] == 'Update Time Slots'
    else
      @event = Event.new(event_params)

      if @event.save
        redirect_to new_time_slot_path(event: @event.id), notice: t('success', model: 'イベント', action: '追加') if params[:commit] == 'Update Event'
        redirect_to events_path, notice: t('success', model: 'イベント', action: '追加') if params[:commit] == 'Update Time Slots'
      else
        render :new, status: :unprocessable_entity, alert: t('failure', model: 'イベント', action: '追加')
      end
    end
  end

  def update
    authorize(:event)

    if params[:event][:school_id] == 'all'
      School.all.each do |school|
        school.events.update(event_params)
      end
      redirect_to new_time_slot_path(event: 'all'), notice: t('success', model: 'イベント', action: '追加') if params[:commit] == 'Update Event'
      redirect_to events_path, notice: t('success', model: 'イベント', action: '追加') if params[:commit] == 'Update Time Slots'
    else
      @event = authorize(Event.find(params[:id]))

      if @event.update(event_params)
        redirect_to new_time_slot_path(event: @event.id), notice: t('success', model: 'イベント', action: '追加') if params[:commit] == 'Update Event'
        redirect_to events_path, notice: t('success', model: 'イベント', action: '追加') if params[:commit] == 'Update Time Slots'
      else
        redirect_to edit_event_path(@event), status: :unprocessable_entity, alert: t('failure', model: 'イベント', action: '追加')
      end
    end
  end

  def destroy
    @event = authorize(Event.find(params[:id]))
    return flash.now[:alert] = t('.event_attended') unless @event.children.empty?

    if @event.destroy
      redirect_to events_path, notice: t('success', model: 'イベント', action: '削除')
    else
      redirect_to event_path(@event), alert: t('failure', model: 'イベント', action: '削除')
    end
  end

  private

  def event_params
    params.require(:event).permit(
      :name, :description, :start_date, :image_id, :end_date, :school_id,
      :member_prices_id, :goal, :non_member_prices_id,
      time_slots_attributes:
        %i[id name start_time end_time category event_id morning morning_slot_id image_id _destroy],
      options_attributes:
        %i[id name cost category modifier optionable_type optionable_id _destroy]
    )
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
