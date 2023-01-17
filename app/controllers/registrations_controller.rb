# frozen_string_literal: true

# Controls flow of information for Registrations
class RegistrationsController < ApplicationController
  def index
    if params[:type] == 'Event'
      slots = Event.find(params[:id]).time_slots
      @registrations = Registration.where(registerable: slots, registerable_type: 'TimeSlot')
    else
      @registrations = Registration.where(registerable_id: params[:id], registerable_type: 'TimeSlot')
    end
  end

  def create
    @registration = Registration.new(reg_params)

    if @registration.save
      flash.now[:notice] = t('.success', registerable: @registration.registerable.name)
      if @registration.slot_registration?
        render @registration
      else
        render @registration.registerable, locals: { child: @registration.child }
      end
    else
      flash.now[:alert] = t('.failure')
    end
  end

  def update
    @registration = Registration.find(params[:id])

    if @registration.update(reg_params)
      flash.now[:notice] = t('.success')
      if @registration.slot_registration?
        render @registration
      else
        render @registration.registerable, locals: { child: @registration.child }
      end
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

  def reg_params
    params.require(:registration).permit(:id, :cost, :child_id,
                                         :registerable_id, :registerable_type,
                                         :billing_date, :confirmed, :paid)
  end
end
