# frozen_string_literal: true

# Handles flow of information for events
class EventsController < ApplicationController
  def show
    @event = Event.find(params[:id])
  end
end
