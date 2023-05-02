# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/invoice
class InvoicePreview < ActionMailer::Preview
  def updated_notif
    InvoiceMailer.with(invoice: Invoice.all.sample(1).first, user: User.first).updated_notif
  end

  def sm_updated_notif
    InvoiceMailer.with(invoice: Invoice.all.sample(1).first, user: User.first).sm_updated_notif
  end
end
