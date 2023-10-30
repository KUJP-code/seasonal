# frozen_string_literal: true

# Provides data for the charts pages
class ChartsController < ApplicationController
  CATEGORIES = %w[activities bookings children coupons edits options].freeze

  def index
    authorize(:chart)
    @nav = nav_data('index')
    @data = send("#{@nav[:category]}_data")
  end

  def show
    @nav = nav_data('show')
    @data = send("#{@nav[:category]}_data")
  end

  private

  def activities_data
    school = @nav[:school]

    if school.id.zero?
      activities_all_data
    else
      activities_school_data(school)
    end
  end

  def activities_all_data
    event_ids = Event.where(name: @nav[:event], school_id: School.real.ids).ids

    @slots = TimeSlot.where(event_id: event_ids)
    @activities = @slots.morning.or(@slots.special)
                        .group(:name).sum(:registrations_count)
    @afternoons = @slots.afternoon.where.not(category: :special)
                        .group(:name).sum(:registrations_count)
  end

  def activities_school_data(school)
    @slots = school.events.find_by(name: @nav[:event]).time_slots
    @activities = @slots.morning.or(@slots.special)
                        .group(:name).sum(:registrations_count)
    @afternoons = @slots.afternoon.where.not(category: :special)
                        .group(:name).sum(:registrations_count)
  end

  def bookings_data
    school = @nav[:school]

    if school.id.zero?
      bookings_all_data
    else
      bookings_school_data(school)
    end
  end

  def bookings_all_data
    events = Event.where(name: @nav[:event], school_id: School.real.ids)
                  .includes(:school)

    @invoices = Invoice.real.where(event_id: events.ids)
    @regs = Registration.where(
      registerable_type: 'TimeSlot',
      invoice_id: @invoices.ids
    )
    @school_hash = events.to_h { |e| [e.id, e.school.name] }
  end

  def bookings_school_data(school)
    event = school.events.find_by(name: @nav[:event])

    @invoices = event.invoices
    @regs = event.registrations
  end

  def children_data
    school = @nav[:school]

    if school.id.zero?
      children_all_data
    else
      children_school_data(school)
    end
  end

  def children_all_data
    @event_ids = Event.where(name: @nav[:event], school_id: School.real.ids).ids
    @children = children_all(@event_ids)
  end

  def children_all(event_ids)
    Child.joins(:real_invoices)
         .where(real_invoices: { event_id: event_ids })
         .includes(:real_invoices)
  end

  def children_school_data(school)
    event = school.events.find_by(name: @nav[:event])

    @children = event.children.includes(:real_invoices)
    @event_ids = [event.id]
    @hat_kids = school.hat_kids
  end

  def coupons_data
    school = @nav[:school]

    event_ids = if school.id.zero?
                  Event.where(name: @nav[:event], school_id: School.real.ids).ids
                else
                  school.events.find_by(name: @nav[:event]).id
                end
    invoice_ids = Invoice.real.where(event_id: event_ids).ids

    @coupons = Coupon.where(couponable_id: invoice_ids)
  end

  def edits_data
    school = @nav[:school]

    @customer_edits = edits_customers(school)
    @staff_edits = edits_staff(school)
  end

  def edits_customers(school)
    customers = if school.id.zero?
                  User.customer.ids
                else
                  school.parents.ids
                end

    PaperTrail::Version.where(
      item_type: 'Invoice',
      event: 'update',
      whodunnit: customers
    ).group_by_day(:created_at).count
  end

  def edits_staff(school)
    staff = if school.id.zero?
              User.staff.ids
            else
              school.managers.ids
            end

    PaperTrail::Version.where(
      item_type: 'Invoice',
      event: 'update',
      whodunnit: staff
    ).group_by_day(:created_at).count
  end

  def nav_data(action)
    {
      category: nav_category,
      categories: CATEGORIES,
      event: params[:event] || Event.last.name,
      events: Event.all.pluck(:name).uniq,
      schools: policy_scope(School),
      school: nav_school(action)
    }
  end

  def nav_category
    CATEGORIES.find { |c| c == params[:category] } || CATEGORIES[0]
  end

  def nav_school(action)
    if action == 'show'
      authorize(School.find(params[:id]))
    else
      School.new(id: 0, name: 'All Schools')
    end
  end

  def options_data
    school = @nav[:school]
    optionable_ids = school.id.zero? ? optionable_ids_all : optionable_ids_school(school)

    @all_opts = options_all(optionable_ids)
    @arrive_opts = options_arrive(optionable_ids)
    @depart_opts = options_depart(optionable_ids)
  end

  def optionable_ids_all
    event_ids = Event.where(
      name: @nav[:event],
      school_id: School.real.ids
    ).ids
    TimeSlot.where(event_id: event_ids).ids.concat(event_ids)
  end

  def optionable_ids_school(school)
    event = school.events.find_by(name: @nav[:event])
    event.time_slots.ids.push(event.id)
  end

  def options_all(optionable_ids)
    Option.where(optionable_id: optionable_ids)
          .joins(:registrations)
  end

  def options_arrive(optionable_ids)
    Option.where(
      optionable_id: optionable_ids,
      category: %i[arrival k_arrival]
    )
          .joins(:registrations)
          .group('options.name')
          .count('options.name')
          .except('なし')
  end

  def options_depart(optionable_ids)
    Option.where(
      optionable_id: optionable_ids,
      category: %i[departure k_departure]
    )
          .joins(:registrations)
          .group('options.name')
          .count('options.name')
          .except('なし')
  end
end
