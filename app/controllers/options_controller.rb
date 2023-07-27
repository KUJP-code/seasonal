# frozen_string_literal: true

# Handles flow of information for Options
class OptionsController < ApplicationController
  def new
    @slot = TimeSlot.find(params[:id])
    @event = @slot.event
  end
end
