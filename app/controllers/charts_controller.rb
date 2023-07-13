# frozen_string_literal: true

# Provides data for the charts pages
class ChartsController < ApplicationController
  def index
    @invoices = Invoice.all
    @children = Child.joins(:real_invoices)
    @slot_registrations = Registration.all.where(registerable_type: 'TimeSlot')
  end

  def show; end
end
