# frozen_string_literal: true

class BulkEventsController < ApplicationController
  after_action :verify_authorized, only: :update
  after_action :verify_policy_scoped, only: %i[index release]

  def index
    @events = policy_scope(Event)

    @selected_events = if params[:name].present?
                         @events.where(name: params[:name])
                       else
                         newest_event = @events.order(start_date: :desc).limit(1).last
                         policy_scope(Event).where(name: newest_event.name)
                       end.includes(:school)
  end

  def update
    @event = authorize Event.find(params[:id])

    if @event.update(event_params)
      redirect_to bulk_events_path(name: @event.name),
                  notice: "Updated #{@event.name} at #{@event.school.name}"
    else
      render :edit,
             status: :unprocessable_entity,
             alert: "Failed to update #{@event.name} at #{@event.school.name}"
    end
  end

  def release
    @events = policy_scope(Event).where(name: params[:name])

    errors = release_events(@events, params[:release] == 'true')

    if errors.empty?
      redirect_to bulk_events_path(name: params[:name]),
                  notice: 'Updated all events'
    else
      redirect_to bulk_events_path(name: params[:name]),
                  alert: "Failed to update #{errors.to_sentence}"
    end
  end

  private

  def event_params
    params.require(:event).permit(:early_bird_date, :early_bird_discount, :goal, :released)
  end

  def release_events(events, released)
    errors = []
    events.each do |event|
      next if event.update(released:)

      errors << event.name
    end

    errors
  end
end
