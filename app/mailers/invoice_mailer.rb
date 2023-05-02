class InvoiceMailer < ApplicationMailer
  default from: 'bookings@kids-up.app'

  def created_notif(invoice)
    @invoice = invoice
    @parent = @invoice.child.parent
    mail(to: @parent.email, subject: t('.invoice_created'))
  end

  def sm_created_notif(invoice)
    @invoice = invoice
    @parent = @invoice.child.parent
    @sm = @invoice.school.managers.first
    mail(to: @sm.email, subject: t('.invoice_created'))
  end

  def updated_notif(invoice)
    @invoice = invoice
    @parent = @invoice.child.parent
    mail(to: @parent.email, subject: t('.invoice_updated'))
  end

  def sm_updated_notif(invoice)
    @invoice = invoice
    @parent = @invoice.child.parent
    @sm = @invoice.school.managers.first
    mail(to: @sm.email, subject: t('.invoice_updated'))
  end
end
