# frozen_string_literal: true

# Sends an invoice update notification to the parent and SM
class InvoiceMailer < ApplicationMailer
  def updated_notif(invoice)
    @invoice = invoice
    @parent = @invoice.child.parent
    mail(to: @parent.email, subject: t('.invoice_updated'))
  end

  def sm_updated_notif(invoice)
    @invoice = invoice
    @parent = @invoice.child.parent
    @sm = @invoice.school.managers.first || User.new(name: 'Emperor Leroy', email: 'h-leroy@kids-up.jp')
    mail(to: @sm.email, subject: t('.invoice_updated'))
  end
end
