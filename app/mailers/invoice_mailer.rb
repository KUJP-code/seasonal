# frozen_string_literal: true

# Sends an invoice update notification to the parent and SM
class InvoiceMailer < ApplicationMailer
  def confirmation_notif
    @invoice = params[:invoice]
    @parent = @invoice.child.parent
    mail(to: @parent.email, subject: t('.invoice_confirm'))
  end

  def updated_notif
    set_shared_vars
    attachments['hello.pdf'] = {
      mime_type: 'application/pdf',
      content: @invoice.pdf
    }
    if @parent.id == @updater.id
      mail(to: @parent.email, subject: t('.booking_made'))
    else
      mail(to: @parent.email, subject: t('.invoice_updated'))
    end
  end

  def sm_updated_notif
    set_shared_vars
    @sm = @invoice.school.managers.first || User.new(name: 'Leroy', email: 'h-leroy@kids-up.jp')
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
