# frozen_string_literal: true

# Provides data for the charts pages
class ChartsController < ApplicationController
  def index
    authorize(:chart)
    @invoices = Invoice.real
    @children = Child.joins(:real_invoices)
    @slot_registrations = Registration.all.where(registerable_type: 'TimeSlot')
  end

  def show; end
end
