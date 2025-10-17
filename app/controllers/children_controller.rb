# frozen_string_literal: true

class ChildrenController < ApplicationController
  # No policy_scope verification as too complex with children attending
  # from different schools. Index action is authorized instead
  after_action :verify_authorized, except: %i[attended_seasonal find_child]

  ALLOWED_SOURCES = %w[event time_slot photo].freeze

  def index
    return show_attendance_sheet if attendance_request?

    authorize Child

    @children = if params[:search]
                  policy_scope(Child).where(search_params)
                else
                  policy_scope(Child.none)
                end.limit(50)
    @events = Event.distinct.pluck(:name) if current_user.admin?
  end

  def show
    @child = authorize Child.find(params[:id])
    @parent = @child.parent
    @events = child_show_events
  end

  def new
    @child = if params[:parent]
               authorize Child.new(parent_id: params[:parent], photos: nil, first_seasonal: true)
             else
               authorize Child.new(photos: nil, first_seasonal: true)
             end
  end

  def edit
    @child = authorize Child.find(params[:id])
  end

  def create
    @child = authorize Child.new(child_params)

    if @child.save
      redirect_to child_path(@child),
                  notice: t('success', action: '追加', model: '生徒')
    else
      render :new,
             status: :unprocessable_entity,
             alert: t('failure', action: '追加', model: '生徒')
    end
  end

  def update
    @child = authorize Child.find(params[:id])

    if @child.update(child_params)
      redirect_to child_path(@child), notice: t('success', action: '更新', model: '生徒')
    else
      render :edit, status: :unprocessable_entity, alert: t('failure', action: '更新', model: '生徒')
    end
  end

  def destroy
    @child = authorize Child.find(params[:id])
    @parent = @child.parent

    if @child.destroy
      redirect_to user_path(current_user), notice: t('success', action: '削除', model: '生徒')
    else
      redirect_to user_path(current_user), alert: t('failure', action: '削除', model: '生徒')
    end
  end

  def attended_seasonal
    authorize Child

    name = params[:event_name]
    children = Child.joins(:invoices)
                    .where(
                      invoices: { event_id: Event.where(name:).select(:id) },
                      children: { first_seasonal: true }
                    )
    children.each { |c| StudentSeasonalUpdateJob.perform_later(c) }

    redirect_to root_path,
                notice: "Updates queued for children who attended #{name}."
  end

  def find_child
    @child = search_result
    @failed = @child ? false : true
    @user = User.find(params[:user])
    return render 'users/_add_child', locals: { user: @user } if params[:bday]

    render 'users/_merge_children', locals: { child: @child }
  end

  private

  def child_params
    params.require(:child).permit(
      :id, :first_name, :family_name, :parent_id, :kana_first, :kana_family,
      :en_name, :category, :birthday, :level, :allergies, :own_snack, :grade, :ssid,
      :ele_school_name, :photos, :first_seasonal, :received_hat, :school_id,
      registrations_attributes:
        %i[child_id registerable_type registerable_id]
    )
  end

  def afternoon_data
    if @afternoon
      @afternoon_children = @afternoon.children.includes(
        :options,
        :parent,
        :registrations,
        :regular_schedule,
        :time_slots
      )
      @afternoon_options = @afternoon.options.not_time
    else
      @afternoon_children = []
      @afternoon_options = []
    end
  end

  def child_show_events
    @child.school
          .events.upcoming.where(released: true)
          .includes(:avif_attachment, :image_attachment)
          .reorder(start_date: :desc)
          .map(&:with_sibling_events)
  end

  def show_attendance_sheet
    case params[:source]
    when 'event'     then event_attendance
    when 'time_slot' then time_slot_attendance
    when 'photo'     then photo_attendance
    end
  end

  def attendance_request?
    params[:source] && ALLOWED_SOURCES.include?(params[:source])
  end

  def event_attendance
    @event = authorize(Event.find(params[:id]), :attendance?)
    @slots = @event.time_slots.morning.or(@event.time_slots.special).distinct
    # this will work as long as photo service is the only event opt
    @photo_kids = Child.where(
      parent_id:
        Child.where(id: @event.options.first.registrations.select(:child_id))
             .select(:parent_id)
    ).ids
    @children = @event.children
                      .includes(:regular_schedule,
                                real_invoices: :coupons)
                      .order(ssid: :desc)
    render 'children/events/event_sheet'
  end

  def search_params
    hash = params.require(:search).permit(
      :email, :en_name, :name, :katakana_name, :ssid
    ).compact_blank.to_h do |k, v|
      if k == 'ssid'
        [k, v.strip]
      else
        [k, "%#{Child.sanitize_sql_like(v.strip)}%"]
      end
    end
    return {} if hash.empty?

    string = hash.keys.map do |k|
      k == 'ssid' ? "children.#{k} = :#{k}" : "#{k} LIKE :#{k}"
    end.join(' AND ')
    [string, hash]
  end

  def search_result
    return Child.find_by(ssid: params[:ssid], birthday: params[:bday]) if params[:bday]

    Child.find_by(ssid: params[:ssid])
  end

  def time_slot_attendance
    build_timeslot_assigns(TimeSlot.find(params[:id]))
    render 'children/time_slots/attendance'
  end

  def photo_attendance
    build_timeslot_assigns(TimeSlot.find(params[:id]))

    photo_child_ids = load_photo_child_ids(@slot.event)

    all_day_children = (@children + @afternoon_children).uniq
    photo_kids = all_day_children.select { |c| photo_child_ids.include?(c.id) }

    @children = photo_kids.select { |c| c.time_slots.include?(@slot) }
    @afternoon_children =
      if @afternoon
        photo_kids.select { |c| c.registered?(@afternoon) }
      else
        []
      end

    render 'children/time_slots/attendance'
  end

  def build_timeslot_assigns(slot)
    @slot = authorize(slot, :attendance?)
    @options = @slot.options
    @event_options = @slot.event.options
    @children = @slot.children
                     .includes(:options, :parent, :registrations, :regular_schedule, :time_slots)

    @afternoon = @slot.afternoon_slot
    afternoon_data

    if @slot.event.respond_to?(:party?) && @slot.event.party?
      @next_party_slot = @slot.event.time_slots.where('start_time > ?',
                                                      @slot.start_time).order(:start_time).first
      @next_party_child_ids =
        if @next_party_slot
          Registration.where(registerable: @next_party_slot).pluck(:child_id).to_set
        else
          Set.new
        end
    else
      @next_party_slot = nil
      @next_party_child_ids = Set.new
    end
  end

  def load_photo_child_ids(event)
    photo_opt = event.options.first!

    direct_ids = Registration.where(registerable: photo_opt).pluck(:child_id).uniq
    parent_ids = Child.where(id: direct_ids).select(:parent_id)
    Child.where(parent_id: parent_ids).pluck(:id)
  end
end
