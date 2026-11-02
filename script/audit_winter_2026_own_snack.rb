# frozen_string_literal: true

# Run with: bundle exec rails runner script/audit_winter_2026_own_snack.rb
# Read-only: never reprices invoices or changes manual adjustments.
require 'json'

report = nil
ApplicationRecord.transaction do
  ApplicationRecord.connection.execute('SET TRANSACTION READ ONLY')
  invoices = Invoice.joins(:event, :child)
                    .where(events: { name: 'ウインタースクール 2026', start_date: Date.new(2026, 12, 14) },
                           children: { own_snack: true })
                    .order(:id)
  rows = invoices.map do |invoice|
    charges = invoice.summary.to_s.scan(/午後コースおやつ代\s*x\s*\d+:\s*([\d,]+)円/)
    snack_cost = charges.sum { |match| match.first.delete(',').to_i }
    { invoice_id: invoice.id, child_id: invoice.child_id, confirmed: invoice.in_ss,
      total_cost: invoice.total_cost, recorded_snack_cost: snack_cost }
  end
  report = { checked_at: Time.current, checked_invoices: rows.size,
             invoices_with_snack_charges: rows.select { |row| row[:recorded_snack_cost].positive? } }
end

puts JSON.pretty_generate(report)
exit 1 if report[:invoices_with_snack_charges].any?
