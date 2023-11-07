# frozen_string_literal: true

class InvoiceMailer < ApplicationMailer
  def confirmation_notif
    @invoice = params[:invoice]
    attachments['invoice.pdf'] = @invoice.pdf
    @parent = @invoice.child.parent
    mail(to: @parent.email, subject: t('.invoice_confirm'))
  end

  def updated_notif
    set_shared_vars
    if @parent.id == @updater.id
      mail(to: @parent.email, subject: t('.booking_made'))
    else
      mail(to: @parent.email, subject: t('.invoice_updated'))
    end
  end

  def sm_updated_notif
    set_shared_vars
    @sm = @invoice.school.manager || User.new(name: 'Leroy', email: 'h-leroy@kids-up.jp')
    mail(to: @sm.email, subject: t('.invoice_updated'))
  end
end

private

def set_shared_vars
  @invoice = params[:invoice]
  @child = @invoice.child
  @updater = if !@invoice.versions.empty? && @invoice.versions.last.whodunnit
               User.find(@invoice.versions.last.whodunnit)
             else
               User.new(name: 'Admin')
             end
  @parent = @child.parent
end
