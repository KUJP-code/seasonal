# frozen_string_literal: true

# Provides data for the charts pages
class ChartsController < ApplicationController
  TEST_SCHOOLS = [1, 2].freeze

# TODO: decide schools based on whether it's an area manager or admin. Probably don't set it at all if an SM

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

  def show
    @schools = School.real
    @school = School.find(params[:id])
  end

  private

  def activity_data
    
  end

  def booking_data
    
  end

  def child_data
    
  end

  def coupon_data
    
  end

  def edit_data
    
  end

  def option_data
    
  end
end
