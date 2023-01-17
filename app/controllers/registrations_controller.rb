# frozen_string_literal: true

# Controls flow of information for Registrations
class RegistrationsController < ApplicationController
  before_action :source, only: [:index]

  def index
    @registrations = @source.registrations.where(registerable_type: 'TimeSlot')
  end

  def create
    @registration = Registration.new(reg_params)

    if @registration.save
      flash.now[:notice] = t('.success', registerable: @registration.registerable.name)
      render @registration if @registration.slot_registration?
      render @registration.registerable, locals: { child: @registration.child } unless @registration.slot_registration?
    else
      flash.now[:alert] = t('.failure')
    end
  end

  def update
    @registration = Registration.find(params[:id])

    if @registration.update(reg_params)
      flash.now[:notice] = t('.success')
      render @registration if @registration.slot_registration?
      render @registration.registerable, locals: { child: @registration.child } unless @registration.slot_registration?
    else
      flash.now[:alert] = t('failure')
    end
  end

  def destroy
    @registration = Registration.find(params[:id])

    if @registration.destroy
      flash.now[:notice] = t('.success', registerable: @registration.registerable.name)
      if @registration.slot_registration?
        render :_unregistered, locals: { child: @registration.child, slot: @registration.registerable }
      else
        render @registration.registerable, locals: { child: @registration.child }
      end
    else
      flash.now[:alert] = t('.failure')
    end
  end

  private

  def source
    case params[:type]
    when 'Event'
      @source = Event.find(params[:id])
    when 'TimeSlot'
      @source = TimeSlot.find(params[:id])
    when 'Child'
      @source = Child.find(params[:id])
    when 'User'
      @source = User.find(params[:id])
    when 'School'
      @source = School.find(params[:id])
    when 'Area'
      @source = Area.find(params[:id])
    else
      render 'errors/unexpected_param'
    end
  end

  def reg_params
    params.require(:registration).permit(:id, :cost, :child_id,
                                         :registerable_id, :registerable_type,
                                         :billing_date, :confirmed, :paid)
  end
end
