# frozen_string_literal: true

# Controls flow of information for Invoices
class InvoicesController < ApplicationController
  def index
    @invoices = if params[:event] && params[:user]
                  User.find(params[:user]).invoices.where(event: Event.find(params[:event]))
                elsif params[:event]
                  current_user.invoices.where(event: Event.find(params[:event]))
                elsif params[:user]
                  User.find(params[:user]).invoices
                else
                  current_user.invoices
                end
  end

  def show
    @invoice = Invoice.find(params[:id])
  end

  def update
    @invoice = Invoice.find(params[:id])

    if @invoice.update(invoice_params)
      @invoice.calc_cost
      flash_success
      redirect_to invoices_path(event: @invoice.event_id, user: @invoice.child.parent_id)
    else
      flash_failure
      render :new, status: :unprocessable_entity
    end
  end

  def confirm
    ignore_slots = invoice_params['slot_regs_attributes'].keep_if { |_, v| v['_destroy'] == '1' }.to_h.transform_values { |v| v['id'].to_i }.values
    ignore_opts = invoice_params['opt_regs_attributes'].keep_if { |_, v| v['_destroy'] == '1' }.to_h.transform_values { |v| v['id'].to_i }.values

    @invoice = Invoice.new(invoice_params)
    @invoice.calc_cost(ignore_slots, ignore_opts)
  end

  def copy
    target = Child.find(params[:target])
    event = Event.find(params[:event])
    origin = Child.find(params[:origin])

    @target_invoice = copy_invoice(target, event, origin)
    @target_invoice.calc_cost

    redirect_to invoice_path(@target_invoice)
  end

  def seen
    Invoice.find(params[:id]).update(seen_at: Time.current)
    @child_id = params[:child]

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def copy_invoice(target, event, origin)
    # List of registrations to copy
    og_regs = origin.invoices.where(event: event).map(&:registrations).flatten
    # Get the target's modifiable invoice, create one if none
    target_invoice = target.invoices.where(event: event).find_by(in_ss: false) || target.invoices.create(event: event)

    og_regs.each do |o_reg|
      # Skip if already on target invoice
      if target_invoice.registrations.any? { |t_reg| t_reg.registerable_id == o_reg.registerable_id && t_reg.registerable_type == o_reg.registerable_type }
        next
      end

      # If not on target invoice, add registration
      target_invoice.registrations.create!(
        child: target,
        registerable_id: o_reg.registerable_id,
        registerable_type: o_reg.registerable_type,
        invoice: target_invoice
      )
    end

    target_invoice
  end

  def flash_failure
    flash.now[:alert] = t('.failure')
  end

  def flash_success
    flash.now[:notice] = t('.success')
  end

  def invoice_params
    params.require(:invoice).permit(
      :id, :child_id, :event_id, :billing_date, :in_ss,
      slot_regs_attributes: %i[id child_id _destroy invoice_id registerable_id
                               registerable_type],
      opt_regs_attributes: %i[id child_id _destroy invoice_id registerable_id
                              registerable_type]
    )
  end
end
