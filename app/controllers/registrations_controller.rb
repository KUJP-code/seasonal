# frozen_string_literal: true

# Controls flow of information for Registrations
class RegistrationsController < ApplicationController
  def create
    @registration = Registration.new(reg_params)

    if @registration.save
      flash.now[:notice] = t('.success', registerable: @registration.registerable.name)
      if @registration.registerable_type == 'TimeSlot'
        render @registration, locals: { child: @registration.child, time_slot: @registration.registerable }
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
      if @registration.registerable_type == 'TimeSlot'
        render @registration, locals: { child: @registration.child, time_slot: @registration.registerable }
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
      if @registration.registerable_type == 'TimeSlot'
        render @registration, locals: { child: @registration.child, time_slot: @registration.registerable }
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
