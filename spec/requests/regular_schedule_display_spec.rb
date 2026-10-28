# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Regular weekdays on booking screens' do
  include ActiveSupport::Testing::TimeHelpers

  let(:child) { create(:internal_child, parent: create(:customer)) }
  let(:event) do
    create(:event, school: child.school, released: true,
                   start_date: Date.new(2026, 12, 15), end_date: Date.new(2026, 12, 24))
  end
  let(:morning) do
    create(:time_slot, :morning, event:, name: '雪だるまアイス',
                                 start_time: Time.zone.local(2026, 12, 15, 10),
                                 end_time: Time.zone.local(2026, 12, 15, 13),
                                 close_at: Time.zone.local(2026, 12, 14))
  end
  let(:other_afternoon) do
    create(:time_slot, :afternoon, event:, name: 'ウィンタースポーツ大会',
                                   start_time: Time.zone.local(2026, 12, 17, 14),
                                   end_time: Time.zone.local(2026, 12, 17, 18),
                                   close_at: Time.zone.local(2026, 12, 16))
  end
  let!(:invoice) { create(:invoice, event:, child:, slot_regs_attributes: slot_attributes) }

  before do
    child.regular_schedules.create!(month: Date.new(2026, 12, 1), tuesday: true, wednesday: true)
  end

  def slot_attributes
    [morning, morning.afternoon_slot, other_afternoon].map do |slot|
      { child_id: child.id, registerable: slot }
    end
  end

  def expect_regular_day_label
    html = Nokogiri::HTML(response.body)
    labels = html.css('.slot_regs .regular-day')
    expect(labels.map(&:text)).to eq(['通学日'])
    heading = html.at_css('.slot_regs h5:not(.text-danger) > .regular-day.text-danger').parent
    expect(heading.text).to include('雪だるまアイス', '(午後)')
  end

  it 'shows current weekdays and only marks matching afternoons for the customer' do
    sign_in child.parent

    get invoice_path(id: invoice.id, locale: :ja)

    expect(response).to have_http_status(:ok)
    expect(Nokogiri::HTML(response.body).at_css('h1 .regular-school-days.d-block.text-danger')
      .text.strip).to eq('12月：火・水')
    expect_regular_day_label

    get child_path(id: child.id, locale: :ja)
    expect(response).to have_http_status(:ok)
    expect(Nokogiri::HTML(response.body).at_css('h1 .regular-school-days.d-block.text-danger')
      .text.strip).to eq('12月：火・水')

    get new_invoice_path(event_id: event.id, child: child.id, locale: :ja)
    expect(response).to have_http_status(:ok)
    expect(Nokogiri::HTML(response.body).at_css('.regular-school-days.d-block.text-danger')
      .text.strip).to eq('12月：火・水')
  end

  it 'shows the same labels for admins and both booking lists' do
    sign_in create(:admin)

    [invoice_path(id: invoice.id), invoices_path(child: child.id),
     invoices_path(user: child.parent_id)].each do |path|
      get path
      expect(response).to have_http_status(:ok)
      expect(Nokogiri::HTML(response.body).at_css('.regular-school-days').text).to include('火・水')
      expect_regular_day_label
    end
  end

  it 'updates annotations without modifying saved summaries, costs or sending emails' do
    sign_in child.parent
    original = invoice.attributes.slice('summary', 'total_cost', 'updated_at')
    child.regular_schedules.first.update!(tuesday: false, wednesday: false, thursday: true)

    expect do
      get invoice_path(id: invoice.id, locale: :ja)
    end.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)

    labels = Nokogiri::HTML(response.body).css('.slot_regs .regular-day')
    expect(labels.size).to eq(1)
    expect(labels.first.parent.text).to include('ウィンタースポーツ大会')
    expect(invoice.reload.attributes.slice('summary', 'total_cost', 'updated_at')).to eq(original)
    expect(invoice.summary).not_to include('通学日')
  end

  it 'keeps regular-day labels on locked bookings after activity names are corrected' do
    invoice.update!(in_ss: true)
    original = invoice.reload.attributes
    sign_in child.parent

    morning.afternoon_slot.update!(name: 'Corrected activity name')
    get invoice_path(id: invoice.id, locale: :ja)

    expect(response).to have_http_status(:ok)
    expect_regular_day_label
    expect(invoice.reload.attributes).to eq(original)
  end

  it 'shows no annotations or empty weekday heading when the schedule is missing' do
    sign_in child.parent
    child.regular_schedules.destroy_all

    get invoice_path(id: invoice.id, locale: :ja)

    html = Nokogiri::HTML(response.body)
    expect(html.css('.regular-day, .regular-school-days')).to be_empty
    expect(html.css('.slot_regs h5').size).to eq(3)
    expect(response.body).not_to include('未通学日', '通学曜日未登録')
  end

  it 'annotates an unsaved booking preview using its selected activities' do
    sign_in child.parent

    selected_slot = { child_id: child.id, registerable_type: 'TimeSlot',
                      registerable_id: morning.afternoon_slot.id }
    post confirm_new_invoice_path(locale: :ja), params: {
      new: 'true',
      invoice: { event_id: event.id, child_id: child.id, slot_regs_attributes: [selected_slot] }
    }

    expect(response).to have_http_status(:ok)
    label = Nokogiri::HTML(response.body).at_css('.slot_regs .regular-day')
    expect(label.text).to eq('通学日')
    expect(label.parent.text).to include('雪だるまアイス', '(午後)')
  end

  it 'keeps months separate and updates locked October bookings after a late upload' do
    event.update!(end_date: Date.new(2027, 2, 5))
    child.update!(ssid: '123456')
    january_slots = [5, 6].map do |day|
      create(:time_slot, :afternoon, event:, name: "January #{day}",
                                     start_time: Time.zone.local(2027, 1, day, 14),
                                     end_time: Time.zone.local(2027, 1, day, 18))
    end
    february_slot = create(:time_slot, :afternoon, event:, name: 'February Wednesday',
                                                   start_time: Time.zone.local(2027, 2, 3, 14),
                                                   end_time: Time.zone.local(2027, 2, 3, 18))
    invoice.update!(slot_regs_attributes: [*january_slots, february_slot].map do |slot|
      { child_id: child.id, registerable: slot }
    end)
    invoice.update!(in_ss: true, created_at: Time.zone.local(2026, 10, 10))
    original = invoice.reload.attributes
    sign_in create(:admin)

    get invoice_path(id: invoice.id)
    expect(Nokogiri::HTML(response.body).css('.regular-day').size).to eq(1)

    travel_to Time.zone.local(2027, 1, 2) do
      sign_out :user
      sign_in create(:admin)
      Tempfile.create(['schedule', '.csv']) do |file|
        file.write("ssid,monday,tuesday,wednesday,thursday,friday\n" \
                   "123456,false,false,true,true,false\n")
        file.flush
        post update_csv_path, params: {
          model: 'RegularSchedule', attendance_month: '2027-01',
          csv: Rack::Test::UploadedFile.new(file.path, 'text/csv')
        }
      end
    end
    expect(flash[:alert]).to be_nil
    sign_in child.parent

    get invoice_path(id: invoice.id, locale: :ja)

    html = Nokogiri::HTML(response.body)
    expect(html.at_css('.regular-school-days').text.strip).to eq('12月：火・水　1月：水・木')
    expect(html.css('.regular-day').map { |label| label.parent.text })
      .to contain_exactly(include('雪だるまアイス'), include('January 6'))
    expect(invoice.reload.attributes).to eq(original)
    expect(child.reload.regular_schedule_for(Date.new(2026, 12, 15)).days).to eq('火, 水')
  end

  it 'does not treat undated legacy schedules as a schedule for every month' do
    child.regular_schedules.destroy_all
    legacy = child.regular_schedules.build(tuesday: true)
    legacy.save!(validate: false)
    sign_in child.parent

    get invoice_path(id: invoice.id, locale: :ja)

    expect(Nokogiri::HTML(response.body).css('.regular-day, .regular-school-days')).to be_empty
  end
end
