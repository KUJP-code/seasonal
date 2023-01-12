# frozen_string_literal: true

# Handles flow of information for Registrations
class RegistrationsController < ApplicationController
  def create
    @registration = Registration.new(reg_params)

    if @registration.save!
      flash[:notice] = t('.success', registerable: @registration.registerable.name)
      redirect_back_or_to child_path(@registration.child)
    else
      flash.now[:alert] = t('.failure')
    end
  end

  def destroy
    @registration = Registration.find(params[:id])

    if @registration.destroy
      flash[:notice] = t('.success', registerable: @registration.registerable.name)
      redirect_back_or_to child_path(@registration.child)
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
