# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/invoice
class InvoicePreview < ActionMailer::Preview
  def confirmation_notif
    InvoiceMailer.with(invoice: Invoice.all.order(:updated_at).last, user: User.first).confirmation_notif
  end

  def updated_notif
    InvoiceMailer.with(invoice: Invoice.all.order(:updated_at).last, user: User.first).updated_notif
  end

  def sm_updated_notif
    InvoiceMailer.with(invoice: Invoice.all.order(:updated_at).last, user: User.first).sm_updated_notif
  end
end
