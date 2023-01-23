# frozen_string_literal: true

# Handles flow of information for events
class EventsController < ApplicationController
  def index
    @events = index_for_role
  end

  def show
    @event = Event.find(params[:id])
  end

  private

  def index_for_role
    return Event.all if current_user.admin?
    return current_user.area_events if current_user.area_manager?
    return current_user.school_events if current_user.school_manager?

    current_user.events
  end
end
