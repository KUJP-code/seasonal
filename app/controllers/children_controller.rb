# frozen_string_literal: true

# Control flow of data for Children
class ChildrenController < ApplicationController
  ALLOWED_SOURCES = %w[Event TimeSlot].freeze

  def index
    authorize :child, :index?
    # List children attending an event or time slot
    if params[:all]
      @source = params[:source].constantize.find(params[:id]) if ALLOWED_SOURCES.include? params[:source]
      @slots = @source.time_slots.morning
      return render 'event_attendance_index'
    elsif params[:source]
      find_source

      return render "#{@source.class.name.downcase}_index"
    end

    # By default, see the list of children current user is responsible for
    @children = policy_scope(Child).page(params[:page]).per(1_000)
  end

  def show
    @child = authorize(Child.find(params[:id]))
  end

  def new
    @child = if params[:parent]
               Child.new(parent_id: params[:parent])
             else
               Child.new
             end
  end

  def edit
    @child = authorize(Child.find(params[:id]))
  end

  def create
    @child = authorize(Child.new(child_params))

    if @child.save
      flash_success
      redirect_to child_path(@child)
    else
      flash_failure
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @child = authorize(Child.find(params[:id]))

    if @child.update(child_params)
      flash_success
      redirect_to child_path(@child), notice: t('success')
    else
      flash_failure
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @child = authorize(Child.find(params[:id]))
    @parent = @child.parent

    if @child.destroy
      redirect_to user_path(@parent), notice: t('success')
    else
      redirect_to child_path(@child), alert: t('failure')
    end
  end

  def find_child
    @child = search_result
    return render 'users/_add_child', locals: { parent: User.find(params[:parent_id]) } if params[:bday]

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

  def find_children
    case params[:source]
    when 'Event'
      @children = @source.children.distinct.includes(
        :regular_schedule, :registrations, :time_slots, :options
      ).includes(invoices: :versions).order(:name)
    when 'TimeSlot'
      @children = @source.children.distinct.includes(options: :registrations).order(:name)
    else
      render status: :unprocessable_entity
    end
  end

  def flash_failure
    flash.now[:alert] = t('.failure')
  end

  def flash_success
    flash.now[:notice] = t('.success')
  end

  def find_source
    @source = params[:source].constantize.find(params[:id]) if ALLOWED_SOURCES.include? params[:source]
    @children = find_children

    @source
  end

  def search_result
    return Child.find_by(ssid: params[:ssid], birthday: params[:bday]) if params[:bday]

    Child.find_by(ssid: params[:ssid])
  end
end
