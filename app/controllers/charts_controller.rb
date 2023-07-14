# frozen_string_literal: true

# Provides data for the charts pages
class ChartsController < ApplicationController
  def index
    authorize(:chart)
    @invoices = Invoice.where('total_cost > 3000').where.not(event_id: TEST_SCHOOLS)
    @children = Child.where.not(school_id: TEST_SCHOOLS).joins(:real_invoices).distinct
    @slot_registrations = Registration.all.where(registerable_type: 'TimeSlot', child_id: @children.ids)
    @school_hash = School.where.not(id: TEST_SCHOOLS).to_h { |school| [school.id, school.name] }
  end

  def show; end

  TEST_SCHOOLS = [1, 2].freeze
end
