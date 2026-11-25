# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriceChange do
  let(:invoice) { create(:invoice) }
  let(:month) { Date.new(2027, 1, 1) }

  def record(old_total, new_total)
    invoice.total_cost = new_total
    described_class.record!(invoice, old_total:, month:)
  end

  it 'keeps the first unseen total when a booking changes again' do
    record(10_000, 12_000)
    record(12_000, 13_000)

    expect(described_class.sole).to have_attributes(old_total: 10_000, new_total: 13_000)
  end

  it 'clears an unseen change when the original total comes back' do
    record(10_000, 12_000)
    record(12_000, 10_000)

    expect(described_class.count).to eq(0)
  end

  it 'starts a new change once the previous one was seen' do
    record(10_000, 12_000)
    described_class.sole.mark_seen!(create(:admin))
    record(12_000, 10_000)

    expect(described_class.unseen.sole).to have_attributes(old_total: 12_000, new_total: 10_000)
    expect(described_class.seen.count).to eq(1)
  end
end
