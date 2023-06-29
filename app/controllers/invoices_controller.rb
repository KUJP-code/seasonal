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
    @invoices.order(updated_at: :desc)
    authorize(@invoices)
    params[:user] ? @user = User.find(params[:user]) : @child = Child.find(params[:child])
  end

  def show
    @invoice = authorize(Invoice.find(params[:id]))
    @updated = true if params[:updated]
    @previous_versions = @invoice.versions.where.not(object: nil).reorder(created_at: :desc).reject{ |v| v.reify.total_cost.zero? }
  end

  def update
    @invoice = authorize(Invoice.find(params[:id]))
    return redirect_to child_path(@invoice.child), alert: t('.no_parent') if @invoice.child.parent_id.nil?

    if params[:commit] == '' || params[:commit] == '✔'
      status_update
    else
      full_update
    end
  end

  def destroy
    @invoice = Invoice.find(params[:id])
    child = @invoice.child

    if @invoice.destroy
      redirect_to invoices_path(child: child.id), notice: t('success', model: 'お申込', action: '削除')
    else
      redirect_to invoice_path(@invoice), notice: t('failure', model: 'お申込', action: '削除')
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

    redirect_to invoice_path(@target_invoice), notice: t('success', model: 'お申込', action: '更新')
  end

  def merge
    merge_from = Invoice.find(params[:merge_from])
    merge_to = Invoice.find(params[:merge_to])

    merge_invoices(merge_from, merge_to)

    merge_from.reload.destroy
    redirect_to invoice_path(merge_to), notice: t('success', model: 'お申込', action: '更新')
  end

  def seen
    @invoice = Invoice.find(params[:id])
    @invoice.update(seen_at: Time.current)

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
      # Skip if already on target invoice or slot is closed
      next unless valid_copy?(o_reg, t_regs)

      registerable_id = if o_reg.registerable_type == 'Option' && origin.kindy != target.kindy
                          find_equivalent_id(o_reg.registerable)
                        else
                          o_reg.registerable_id
                        end

      # If not on target invoice, add registration
      target_invoice.registrations.create!(
        child: target,
        registerable_id: registerable_id,
        registerable_type: o_reg.registerable_type,
        invoice: target_invoice
      )
    end

    target_invoice.reload.save
    target_invoice
  end

  def find_equivalent_id(option)
    return option.id unless %w[arrival k_arrival departure k_departure extension k_extension].include?(option.category)

    # Switch the category to the correct one for target's kindy/elementary
    category = option.category
    equivalent_category = if category.start_with?('k_')
                            category.gsub('k_', '')
                          else
                            "k_#{category}"
                          end

    # Find and return the equivalent option's id
    option.optionable.options.find_by(name: option.name, category: equivalent_category).id
  end

  def full_update
    if @invoice.update(invoice_params)
      # FIXME: bandaid to cover for the fact that some callbacks don't
      # update the summary (adjustments, option registrations)
      @invoice.reload.calc_cost && @invoice.save
      send_emails(@invoice)
      redirect_to invoice_path(id: @invoice.id, updated: true), notice: t('success', model: 'お申込', action: '更新')
    else
      render :new, status: :unprocessable_entity, notice: t('failure', model: 'お申込', action: '更新')
    end
  end

  def merge_invoices(from, to)
    from.registrations.each do |reg|
      reg.update(invoice_id: to.id)
    end

    from_adj = from.adjustments
    to_adj = to.adjustments
    from_adj.each do |adj|
      next if to_adj.any? { |ta| ta.reason == adj.reason }

      to.adjustments << adj
    end

    to.save
  end

  def send_emails(invoice)
    # Send the confirmation email when in_ss is set to true
    # otherwise notify user and SM the booking has been modified
    if invoice_params['in_ss'] == 'true'
      InvoiceMailer.with(invoice: invoice, user: invoice.child.parent).confirmation_notif.deliver_now
    else
      unless current_user.admin?
        InvoiceMailer.with(invoice: invoice, user: invoice.child.parent).updated_notif.deliver_now
        InvoiceMailer.with(invoice: invoice, user: invoice.school.managers.first).sm_updated_notif.deliver_now
      end
    end
  end

  def status_update
    @child_invoices = @invoice.child.real_invoices.where(event_id: @invoice.event_id)

    if @invoice.update(invoice_params)
      respond_to do |format|
        format.turbo_stream
      end
    else
      redirect_to invoice_path(@invoice), status: :unprocessable_entity, notice: t('failure', model: 'お申込', action: '更新')
    end
  end

  def valid_copy?(o_reg, t_regs)
    # Check if slot is closed (when slot reg)
    return false if o_reg.registerable_type == 'TimeSlot' && o_reg.registerable.closed?
    # Check if target already registered
    return false if already_registered?(t_regs, o_reg)

    true
  end

  def invoice_params
    params.require(:invoice).permit(
      :id, :child_id, :event_id, :billing_date, :in_ss, :entered,
      slot_regs_attributes: %i[id child_id _destroy invoice_id registerable_id
                               registerable_type],
      opt_regs_attributes: %i[id child_id _destroy invoice_id registerable_id
                              registerable_type],
      coupons_attributes: [:code],
      adjustments_attributes: %i[id reason change invoice_id _destroy]
    )
  end
end
