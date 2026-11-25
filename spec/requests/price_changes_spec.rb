# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Booking price changes' do
  let(:school) { create(:school) }
  let(:manager) { create(:school_manager, allowed_ips: ['*']) }
  let(:child) { create(:internal_child, school:, ssid: 2_504_000_197) }
  let(:invoice) { create(:invoice, child:) }
  let!(:change) do
    invoice.total_cost = 13_700
    PriceChange.record!(invoice, old_total: 10_900, month: Date.new(2027, 1, 1))
    PriceChange.sole
  end

  before do
    manager.managements.create!(manageable: school)
    sign_in manager
  end

  it 'alerts the school manager on every page until each change is ticked' do
    get user_path(manager, locale: :ja)

    expect(response.body).to include('確認が必要なお申込が1件あります')
    expect(response.body).to include(price_changes_path(locale: :ja))

    change.mark_seen!(manager)
    get user_path(manager, locale: :ja)

    expect(response.body).not_to include('確認が必要なお申込が')
  end

  it 'still alerts a school manager outside the school' do
    manager.update!(allowed_ips: ['10.0.0.1'])

    get user_path(manager, locale: :ja), env: { 'REMOTE_ADDR' => '10.0.0.2' }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('確認が必要なお申込が1件あります')
  end

  it 'lists the student, SSID, booking and totals' do
    get price_changes_path(locale: :ja)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(child.name, '2504000197', invoice_path(invoice, locale: :ja),
                                     '10,900円', '13,700円', '+2,800円', '2027年1月分の通学曜日')
  end

  it 'explains review and double-booking entries' do
    PriceChange.record!(invoice, kind: :needs_review, old_total: 10_900,
                                 month: Date.new(2027, 1, 1), new_total: 8100)
    PriceChange.sync_double_booking!(invoice, [Date.new(2026, 12, 28), Date.new(2027, 1, 4)])

    get price_changes_path(locale: :ja)

    expect(response.body).to include('要確認（手動調整あり）', '（未反映）', '-2,800円',
                                     '通学日に通常レッスン', '12/28(月), 1/4(月)')
  end

  it 'marks a change seen and can untick it' do
    patch price_change_path(change, locale: :ja), params: { seen: '1' }, as: :turbo_stream

    expect(change.reload).to have_attributes(seen_by: manager)
    expect(response.body).to include('確認済み')

    patch price_change_path(change, locale: :ja), as: :turbo_stream

    expect(change.reload).to have_attributes(seen_at: nil, seen_by: nil)
  end

  it "hides other schools' changes" do
    other = create(:school_manager, allowed_ips: ['*'])
    other.managements.create!(manageable: create(:school))
    sign_in other

    get price_changes_path(locale: :ja)
    expect(response.body).not_to include(child.name)
    expect(response.body).not_to include('確認が必要なお申込が')

    patch price_change_path(change, locale: :ja), params: { seen: '1' }
    expect(change.reload.seen_at).to be_nil
  end
end
