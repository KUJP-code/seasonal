# frozen_string_literal: true

# Sends an invoice update notification to the parent and SM
class InvoiceMailer < ApplicationMailer
  def confirmation_notif
    @invoice = params[:invoice]
    @parent = @invoice.child.parent
    mail(to: @parent.email, subject: t('.invoice_confirm'))
  end

  def updated_notif
    @invoice = params[:invoice]
    @updater = @invoice.versions.last.whodunnit ? User.find(@invoice.versions.last.whodunnit) : User.new(name: 'Admin')
    @child = @invoice.child
    @parent = @child.parent
    if @parent.id == @updater.id
      mail(to: @parent.email, subject: t('.booking_made'))
    else
      mail(to: @parent.email, subject: t('.invoice_updated'))
    end
  end

  def sm_updated_notif
    @invoice = params[:invoice]
    @updater = @invoice.versions.last.whodunnit ? User.find(@invoice.versions.last.whodunnit) : User.new(name: 'Admin')
    @child = @invoice.child
    @parent = @child.parent
    @sm = @invoice.school.managers.first || User.new(name: 'Leroy', email: 'h-leroy@kids-up.jp')
    mail(to: @sm.email, subject: t('.invoice_updated'))
  end
end
