# frozen_string_literal: true

class InvoiceMailer < ApplicationMailer
  default from: 'bookings@kids-up.app'

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
