# frozen_string_literal: true

# Controls flow of information for Invoices
class InvoicesController < ApplicationController
  def show
    @invoice = Invoice.find(params[:id])
  end

  def update
    @invoice = Invoice.find(params[:id])

    if @invoice.update(invoice_params)
      # TODO: make sure this actually updates the cost later
      @invoice.calc_cost
      flash_success
      redirect_to invoice_path(@invoice)
    else
      flash_failure
      render event_path(@invoice.event), status: :unprocessable_entity
    end
  end

  private

  def flash_failure
    flash.now[:alert] = t('.failure')
  end

  def flash_success
    flash.now[:notice] = t('.success')
  end

  def invoice_params
    params.require(:invoice).permit(
      :id, :total_cost, :billing_date, :summary, :in_ss, :paid, :email_sent,
      slot_regs_attributes: %i[id child_id invoice_id registerable_id
                               registerable_type],
      opt_regs_attributes: %i[id child_id invoice_id registerable_id
                              registerable_type]
    )
  end
end
