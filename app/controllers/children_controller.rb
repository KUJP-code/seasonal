# frozen_string_literal: true

# Control flow of data for Children
class ChildrenController < ApplicationController
  ALLOWED_SOURCES = %w[Event TimeSlot].freeze

  def index
    authorize :child, :index?
    # List children attending an event or time slot
    if params[:all]
      slot_attendance_index
    elsif params[:source]
      return unless ALLOWED_SOURCES.include? params[:source]

      find_source
    else
      # By default, see the list of children current user is responsible for
      @children = policy_scope(Child).page(params[:page]).per(1_000)
    end
  end

  def show
    @child = authorize(Child.find(params[:id]))
  end

  def new
    @child = if params[:parent]
               Child.new(parent_id: params[:parent], photos: nil, needs_hat: false)
             else
               Child.new(photos: nil, needs_hat: false)
             end
  end

  def edit
    @child = authorize(Child.find(params[:id]))
  end

  def create
    @child = authorize(Child.new(child_params))

    if @child.save
      redirect_to child_path(@child), notice: t('success', action: '追加', model: '生徒')
    else
      render :new, status: :unprocessable_entity, alert: t('failure', action: '追加', model: '生徒')
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
      redirect_to user_path(@parent), notice: t('success', action: '削除', model: '生徒')
    else
      redirect_to child_path(@child), alert: t('failure', action: '削除', model: '生徒')
    end
  end

  def find_child
    @child = search_result
    return render 'users/_add_child', locals: { parent: User.find(params[:parent_id]) } if params[:bday]

    @parent = User.find(params[:parent])
    render 'users/_merge_children', locals: { child: @child } if @child.present?
  end

  private

  def child_params
    params.require(:child).permit(:id, :first_name, :family_name,
                                  :kana_first, :kana_family, :en_name, :category, :birthday, :level, :allergies,
                                  :grade, :ssid, :ele_school_name,
                                  :photos, :needs_hat, :first_seasonal,
                                  :received_hat, :parent_id, :school_id,
                                  registrations_attributes: %i[
                                    child_id registerable_type
                                    registerable_id
                                  ])
  end

  def customer_show
    @slots = @next_event.time_slots.limit(5)
  end

  def event_variables
    @source = Event.find(params[:id])
    @slots = @source.time_slots.includes(:options)
    @children = @source.children.includes(
      :options, :regular_schedule, time_slots: %i[options afternoon_slot], invoices: :coupons
    ).order(:name)
  end

  def find_source
    case params[:source]
    when 'Event'
      event_variables
      render 'children/events/event_sheet'
    when 'TimeSlot'
      slot_variables
      render 'children/time_slots/slot_sheet'
    end
  end

  def search_result
    return Child.find_by(ssid: params[:ssid], birthday: params[:bday]) if params[:bday]

    Child.find_by(ssid: params[:ssid])
  end

  def slot_attendance_index
    @source = Event.where(id: params[:id]).includes(options: :registrations)
    @slots = @source.first.time_slots.morning.includes(
      children: :registrations, afternoon_slot: %i[options registrations],
      options: :registrations
    )
    render 'children/time_slots/slot_sheet_index'
  end

  def slot_variables
    @source = TimeSlot.where(id: params[:id]).includes(
      children: :registrations, afternoon_slot: %i[options registrations],
      options: :registrations
    )
    @event = Event.where(id: @source.first.event_id).includes(options: :registrations)
  end
end
