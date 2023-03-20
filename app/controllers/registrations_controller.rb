# frozen_string_literal: true

# Controls flow of information for Registrations
class RegistrationsController < ApplicationController
  def index
    @source = check_source
    @registrations = @source.slot_registrations
    @slots = @source.time_slots.distinct
  end

  def create
    @registration = Registration.new(reg_params)
    return redirect_to :reg_error if registered? || overbooked?

    respond_to do |format|
      if @registration.save
        flash_success
        format.turbo_stream
      else
        flash_failure
      end
    end
  end

  def update
    @registration = Registration.find(params[:id])

    if @registration.update(reg_params)
      flash_success
    else
      flash_failure
    end
    render_flash
  end

  def destroy
    @registration = Registration.find(params[:id])

    respond_to do |format|
      if @registration.destroy
        flash_success
        format.turbo_stream
      else
        flash_failure
      end
    end
  end

  private

  def check_source
    raise StandardError, "unexpected source request: #{params[:source]}" unless %w[Child User].include? params[:source]

    params[:source].constantize.find(params[:id])
  end

  def flash_failure
    flash.now[:alert] = t('.failure', target: @registration.registerable.name, child: @registration.child.name)
  end

  def flash_success
    flash.now[:notice] = t('.success', target: @registration.registerable.name, child: @registration.child.name)
  end

  def overbooked?
    return false unless @registration.slot_registration?

    slot = @registration.registerable
    return false if slot.max_attendees.nil?

    slot.children.ids.size >= slot.max_attendees
  end

  def render_flash
    render turbo_stream: turbo_stream.update('flash', partial: 'shared/flash')
  end

  def registered?
    Registration.find_by(child_id: @registration.child_id,
                         registerable_id: @registration.registerable_id,
                         registerable_type: @registration.registerable_type)
  end

  def reg_params
    params.require(:registration).permit(:id, :child_id,
                                         :registerable_id, :registerable_type,
                                         :billing_date, :confirmed, :paid)
  end
end
