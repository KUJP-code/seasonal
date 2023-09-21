# frozen_string_literal: true

# Provides data for the charts pages
class ChartsController < ApplicationController
  def index
    authorize(:chart)
    @invoices = Invoice.where('total_cost > 3000').where.not(event_id: TEST_SCHOOLS).includes(:child)
    @coupons = Coupon.where(couponable_id: @invoices.ids)
    @children = Child.where.not(school_id: TEST_SCHOOLS).joins(:real_invoices).distinct
    @slot_registrations = Registration.all.where(registerable_type: 'TimeSlot', child_id: @children.ids)
    @school_hash = School.real.to_h { |school| [school.id, school.name] }
    @time_slots = TimeSlot.where(morning: true, category: %i[seasonal outdoor]).or(TimeSlot.where(category: :special))
    @versions = PaperTrail::Version.where(item_type: 'Invoice', event: 'update')
  end

  def show; end

  TEST_SCHOOLS = [1, 2].freeze
end
