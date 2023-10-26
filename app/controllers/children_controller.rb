# frozen_string_literal: true

# Control flow of data for Children
class ChildrenController < ApplicationController
  ALLOWED_SOURCES = %w[event time_slot].freeze

  def index
    authorize(:child)
    return send("#{params[:source]}_attendance") if attendance_request?

    return admin_index if current_user.admin?

    @children = policy_scope(Child).page(params[:page]).per(1_000)
  end

  def show
    @child = authorize(Child.find(params[:id]))
  end

  def new
    @child = if params[:parent]
               Child.new(parent_id: params[:parent], photos: nil, first_seasonal: true)
             else
               Child.new(photos: nil, first_seasonal: true)
             end
  end

  def edit
    @child = authorize(Child.find(params[:id]))
  end

  def create
    @child = authorize(Child.new(child_params))

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
    @child = authorize(Child.find(params[:id]))

    if @child.update(child_params)
      redirect_to child_path(@child), notice: t('success', action: '更新', model: '生徒')
    else
      render :edit, status: :unprocessable_entity, alert: t('failure', action: '更新', model: '生徒')
    end
  end

  def destroy
    @child = authorize(Child.find(params[:id]))
    @parent = @child.parent

    if @child.destroy
      redirect_to user_path(current_user), notice: t('success', action: '削除', model: '生徒')
    else
      redirect_to user_path(current_user), alert: t('failure', action: '削除', model: '生徒')
    end
  end

  def find_child
    @child = search_result
    @failed = @child ? false : true
    return render 'users/_add_child', locals: { parent: User.find(params[:parent_id]) } if params[:bday]

    @parent = User.find(params[:parent])
    render 'users/_merge_children', locals: { child: @child } if @child.present?
  end

  private

  def child_params
    params.require(:child).permit(:id, :first_name, :family_name,
                                  :kana_first, :kana_family, :en_name, :category, :birthday, :level, :allergies,
                                  :grade, :ssid, :ele_school_name,
                                  :photos, :first_seasonal,
                                  :received_hat, :parent_id, :school_id,
                                  registrations_attributes: %i[
                                    child_id registerable_type
                                    registerable_id
                                  ])
  end

  def admin_index
    @schools = School.real.order(:id)
    @school = params[:school] ? School.find(params[:school]) : @schools.first
    @children = @school.children
                       .includes(:parent)
                       .page(params[:page]).per(1_000)
  end

  def afternoon_data
    @afternoon_children = @afternoon.children.includes(
      :options,
      :parent,
      :registrations,
      :regular_schedule,
      :time_slots
    )
    @afternoon_options = @afternoon.options.not_time
  end

  def attendance_request?
    params[:source] && ALLOWED_SOURCES.include?(params[:source])
  end

  def event_attendance
    @source = Event.find(params[:id])
    @slots = @source.time_slots.includes(:options)
    @children = @source.children.includes(
      :options, :invoices, :regular_schedule, time_slots: %i[options afternoon_slot], real_invoices: :coupons
    ).order(:name)
    render 'children/events/event_sheet'
  end

  def search_result
    return Child.find_by(ssid: params[:ssid], birthday: params[:bday]) if params[:bday]

    Child.find_by(ssid: params[:ssid])
  end

  def time_slot_attendance
    @slot = TimeSlot.find(params[:id])
    @options = @slot.options
    @event_options = @slot.event.options
    @children = @slot.children.includes(
      :options,
      :parent,
      :registrations,
      :regular_schedule,
      :time_slots
    )
    @afternoon = @slot.afternoon_slot
    afternoon_data if @afternoon

    render 'children/time_slots/attendance'
  end
end
