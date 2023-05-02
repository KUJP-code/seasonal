# frozen_string_literal: true

# Controls flow of information for Invoices
class InvoicesController < ApplicationController
  def index
    @invoices = if params[:event] && params[:user]
                  User.find(params[:user]).invoices.where(event: Event.find(params[:event]))
                elsif params[:user]
                  User.find(params[:user]).invoices
                elsif params[:child]
                  Child.find(params[:child]).invoices
                else
                  current_user.invoices
                end
    authorize(@invoices)
    params[:user] ? @user = User.find(params[:user]) : @child = Child.find(params[:child])
  end

  def show
    @invoice = authorize(Invoice.find(params[:id]))
    @previous_versions = @invoice.versions.where.not(object: nil)
  end

  def update
    @invoice = authorize(Invoice.find(params[:id]))

    if @invoice.update(invoice_params)
      @invoice.calc_cost
      send_emails(@invoice)
      redirect_to invoice_path(@invoice), notice: t('update_success')
    else
      render :new, status: :unprocessable_entity, notice: t('update_failure')
    end
  end

  def destroy
    @invoice = Invoice.find(params[:id])
    child = @invoice.child

    if @invoice.destroy
      redirect_to invoices_path(child: child.id), notice: t('delete_success')
    else
      redirect_to invoice_path(@invoice), notice: t('delete_failure')
    end
  end

  def confirm
    ignore_slots = if invoice_params['slot_regs_attributes'].nil?
                     []
                   else
                     invoice_params['slot_regs_attributes'].keep_if do |_, v|
                       v['_destroy'] == '1'
                     end.to_h.transform_values do |v|
                       v['id'].to_i
                     end.values
                   end
    ignore_opts = if invoice_params['opt_regs_attributes'].nil?
                    []
                  else
                    invoice_params['opt_regs_attributes'].keep_if do |_, v|
                      v['_destroy'] == '1'
                    end.to_h.transform_values do |v|
                      v['id'].to_i
                    end.values
                  end

    @invoice = authorize(Invoice.new(invoice_params))
    @invoice.calc_cost(ignore_slots, ignore_opts)
    @ss_invoices = Invoice.where(event_id: @invoice.event_id, in_ss: true, child_id: @invoice.child_id)
  end

  def confirmed
    @invoice = nil

    render 'invoices/confirm'
  end

  def copy
    target = Child.find(params[:target])
    event = Event.find(params[:event])
    origin = Child.find(params[:origin])

    @target_invoice = authorize(copy_invoice(target, event, origin))
    @target_invoice.calc_cost

    redirect_to invoice_path(@target_invoice)
  end

  def merge
    merge_from = Invoice.find(params[:merge_from])
    merge_to = Invoice.find(params[:merge_to])

    merge_invoices(merge_from, merge_to)

    merge_from.reload.destroy
    merge_to.calc_cost
    redirect_to invoice_path(merge_to)
  end

  def resurrect
    @version = Invoice.find(params[:id]).versions.find(params[:version])

    return redirect_to invoice_path(params[:id]), alert: t('.resurrection_failure') unless @version.reify

    @version.reify.save

    redirect_to invoice_path(params[:id]), notice: t('.resurrection_success')
  end

  def seen
    Invoice.find(params[:id]).update(seen_at: Time.current)
    @child_id = params[:child]

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def already_registered?(t_regs, o_reg)
    t_regs.any? do |t_reg|
      t_reg.registerable_id == o_reg.registerable_id && t_reg.registerable_type == o_reg.registerable_type
    end
  end

  def copy_invoice(target, event, origin)
    # List of registrations to copy
    og_regs = origin.invoices.where(event: event).map(&:registrations).flatten
    # Get the target's modifiable invoice, create one if none
    target_invoice = target.invoices.where(event: event).find_by(in_ss: false) || target.invoices.create(event: event)
    t_regs = target.invoices.where(event: event).reduce([]) { |a, i| a + i.registrations }

    og_regs.each do |o_reg|
      # Skip if already on target invoice
      next if already_registered?(t_regs,
                                  o_reg) || (o_reg.registerable_type == 'TimeSlot' && o_reg.registerable.closed?)

      # If not on target invoice, add registration
      target_invoice.registrations.create!(
        child: target,
        registerable_id: o_reg.registerable_id,
        registerable_type: o_reg.registerable_type,
        invoice: target_invoice
      )
    end

    target_invoice.save
    target_invoice
  end

  def merge_invoices(from, to)
    from.registrations.each do |reg|
      reg.update(invoice_id: to.id)
    end

    from_adj = from.adjustments
    to_adj = to.adjustments
    from_adj.each do |adj|
      next if to_adj.any? { |ta| ta.reason == adj.reason }

      adj.update(invoice_id: to.id)
    end
  end

  def invoice_params
    params.require(:invoice).permit(
      :id, :child_id, :event_id, :billing_date, :in_ss,
      slot_regs_attributes: %i[id child_id _destroy invoice_id registerable_id
                               registerable_type],
      opt_regs_attributes: %i[id child_id _destroy invoice_id registerable_id
                              registerable_type],
      coupons_attributes: [:code],
      adjustments_attributes: %i[id reason change invoice_id _destroy]
    )
  end

  def send_emails(invoice)
    InvoiceMailer.updated_notif(invoice).deliver_later
    InvoiceMailer.sm_updated_notif(invoice).deliver_later
  end
end
