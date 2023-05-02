# Preview all emails at http://localhost:3000/rails/mailers/invoice
class InvoicePreview < ActionMailer::Preview
  def created_notif
    InvoiceMailer.created_notif(Invoice.all.sample(1).first)
  end

  def sm_created_notif
    InvoiceMailer.sm_created_notif(Invoice.all.sample(1).first)
  end

  def updated_notif
    InvoiceMailer.updated_notif(Invoice.all.sample(1).first)
  end

  def sm_updated_notif
    InvoiceMailer.sm_updated_notif(Invoice.all.sample(1).first)
  end
end
