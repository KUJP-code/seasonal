# frozen_string_literal: true

class ChartsController < ApplicationController
  CATEGORIES = %w[summaries setsumeikais bookings activities children options edits coupons].freeze
  after_action :verify_authorized

  def index
    authorize(:chart)
    @nav = nav_data('index')
    send(:"#{@nav[:category]}_data")
  end

  def show
    authorize(:chart)
    @nav = nav_data('show')
    send(:"#{@nav[:category]}_data")
  end

  private

  def activities_data
    @school = @nav[:school]

    if @school.id.zero?
      activities_all_data
    else
      activities_school_data(@school)
    end
  end

  def activities_all_data
    @events = Event.where(name: @nav[:event],
                          school_id: School.real.select(:id))
                   .includes(:school)

    @slots = TimeSlot.where(event_id: @events.ids)
    @activities = @slots.morning.or(@slots.special)
                        .group(:name).sum(:registrations_count)
    @afternoons = @slots.afternoon.where.not(category: :special)
                        .group(:name).sum(:registrations_count)
    @date_attendance = @slots.group_by_day(:start_time).group(:event_id)
                             .sum(:registrations_count)
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
      @event = Event.find_by(name: @nav[:event], school_id: school.id)
    end
  end

  def bookings_all_data
    events = Event.where(name: @nav[:event],
                         school_id: School.real.select(:id))
                  .includes(:school)

    @invoices = Invoice.real.where(event_id: events.ids)
    @regs = Registration.where(
      registerable_type: 'TimeSlot',
      invoice_id: @invoices.ids
    )
    @school_hash = events.to_h { |e| [e.id, t("schools.#{e.school.name}")] }
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
    @event_ids = Event.where(name: @nav[:event],
                             school_id: School.real.select(:id)).ids
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
                  Event.where(name: @nav[:event],
                              school_id: School.real.select(:id)).ids
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
      area: nav_area(action),
      areas: policy_scope(Area),
      category: nav_category,
      categories: CATEGORIES,
      event: params[:event] || Event.last.name,
      events: Event.distinct.pluck(:name),
      schools: nav_schools,
      school: nav_school(action)
    }
  end

  def nav_area(action)
    if action == 'index'
      if params[:area_id].to_i.zero?
        Area.new(id: 0,
                 name: 'All Areas')
      else
        authorize(Area.find(params[:area_id]))
      end
    else
      Area.new(id: 0, name: 'All Areas')
    end
  end

  def nav_category
    CATEGORIES.find { |c| c == params[:category] } || CATEGORIES[0]
  end

  def nav_school(action)
    if action == 'show'
      authorize(School.find(params[:id]))
    elsif current_user.admin? || current_user.statistician?
      School.new(id: 0, name: 'All Schools')
    else
      School.new(id: 0, name: 'Area Schools')
    end
  end

  def nav_schools
    scoped_schools = policy_scope(School)
    return scoped_schools if params[:area_id].nil? || params[:area_id].to_i.zero?

    scoped_schools.where(area_id: params[:area_id])
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
      school_id: School.real.select(:id)
    ).ids
    TimeSlot.where(event_id: event_ids).ids + event_ids
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

  def setsumeikais_data
    if @nav[:school].id.zero?
      area_scoped_setsu
    else
      school_scoped_setsu
    end

    set_month
    set_monthly_setsu
    set_daily_inquiries
  end

  def area_scoped_setsu
    ids = area_school_ids
    @setsumeikais = policy_scope(Setsumeikai).where(school_id: ids)
    @inquiries = policy_scope(Inquiry).where(school_id: ids)
  end

  def area_school_ids
    return policy_scope(School).ids if @nav[:area].id.zero?

    policy_scope(School).where(area_id: @nav[:area].id).ids
  end

  def school_scoped_setsu
    @setsumeikais = policy_scope(Setsumeikai).where(school_id: @nav[:school].id)
    @inquiries = policy_scope(Inquiry).where(school_id: @nav[:school].id)
  end

  def set_month
    @month = if params[:month]
               Date.parse(params[:month])
             else
               Time.zone.now.at_beginning_of_month
             end
  end

  def set_daily_inquiries
    @daily_inquiries = @inquiries
                       .where(created_at: @month..@month.end_of_month)
                       .group(:school_id)
                       .group_by_day(:created_at)
                       .count
  end

  def set_monthly_setsu
    setsu = @setsumeikais
            .where(start: @month..@month.end_of_month)
            .group(:school_id)
            .order(school_id: :asc)
    setsu_count = setsu.count
    setsu_slots = setsu.sum(:attendance_limit)
    setsu_attendance = setsu.sum(:inquiries_count)

    @monthly_setsu = setsu.pluck(:school_id).index_with do |school|
      {
        count: setsu_count[school],
        slots: setsu_slots[school],
        attendance: setsu_attendance[school]
      }
    end
  end

  def summaries_data
    @events_for_summary =
      Event.where(name: @nav[:event], school_id: School.real.select(:id))
           .includes(:school, :children, :invoices, options: :registrations)
  end
end
