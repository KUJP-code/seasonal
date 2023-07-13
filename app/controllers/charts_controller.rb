# frozen_string_literal: true

# Provides data for the charts pages
class ChartsController < ApplicationController
  def index
    authorize(:chart)
    @invoices = Invoice.where('total_cost > 3000')
    @children = Child.joins(:real_invoices).distinct
    @slot_registrations = Registration.all.where(registerable_type: 'TimeSlot')
    @school_hash = School.all.to_h { |school| [school.id, school.name] }
  end

  def show; end
end
