# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Afternoon-only activities' do
  let(:event) { create(:event) }
  let(:start_time) { event.start_date.in_time_zone.change(hour: 14) }

  context 'when managing activities' do
    let(:activity_attributes) do
      { name: 'Afternoon Science', morning: 'false', category: 'seasonal',
        start_time:, end_time: start_time + 3.hours,
        close_at: start_time - 1.day }
    end

    before { sign_in create(:admin) }

    it 'offers afternoon-only creation and retains existing afternoon activities' do
      slot = create(:time_slot, :afternoon, event:, name: 'Existing Afternoon')

      get new_time_slot_path(event: event.id)

      expect(response).to have_http_status(:ok)
      html = Nokogiri::HTML(response.body)
      expect(html.css('option[value="false"]').map(&:text)).to include('Afternoon only (PM)')
      expect(html.at_css("input[value='#{slot.name}']")).to be_present
      expect(html.at_css('template option[value="true"][selected]')).to be_present
      expect(html.css('input[name$="[snack]"]')).to be_empty
    end

    it 'creates an independent afternoon activity at one school' do
      patch event_path(id: event.id), params: {
        event: { school_id: event.school_id, time_slots_attributes: { '0' => activity_attributes } }
      }

      expect(response).to redirect_to(
        time_slots_path(event: event.id, school: event.school_id, locale: :en)
      )
      slot = event.time_slots.sole
      expect(slot).to have_attributes(morning: false, morning_slot_id: nil, snack: true)
      expect(slot.start_time).to eq(start_time)
      expect(slot.options.departure.count).to eq(4)
    end

    it 'adds afternoon activities to all 40 schools alongside their existing morning activities' do
      # Exercise the full forty-school workflow.
      # rubocop:disable FactoryBot/ExcessiveCreateList
      schools = create_list(:school, 40)
      # rubocop:enable FactoryBot/ExcessiveCreateList
      prices = create(:member_prices)
      events = schools.map do |school|
        create(:event, name: 'Winter School', school:,
                       member_prices: prices, non_member_prices: prices)
      end
      mornings = events.map { |school_event| create(:time_slot, :morning, event: school_event) }
      first_event = events.first

      get new_time_slot_path(event: first_event.name, all_schools: true)
      expect(response).to have_http_status(:ok)
      html = Nokogiri::HTML(response.body)
      slot_ids = html.css('input[name*="time_slots_attributes"][name$="[id]"]')
                     .filter_map { |input| input['value'].presence }
      expect(slot_ids).to be_empty

      patch event_path(id: first_event.id), params: {
        event: { name: first_event.name, time_slots_attributes: { '0' => activity_attributes } }
      }

      expect(response).to redirect_to(events_path(locale: :en))
      events.each do |school_event|
        slot = school_event.time_slots.find_by!(name: 'Afternoon Science')
        expect(slot).to have_attributes(morning: false, morning_slot_id: nil, snack: true)
        expect(school_event.time_slots.count).to eq(3)
      end
      mornings.each do |slot|
        expect(slot.reload).to be_morning
        expect(slot.afternoon_slot).to be_present
      end
      expect(event.time_slots).to be_empty
    end

    it 'lists standalone afternoons for staff and event attendance' do
      slot = create(:time_slot, :afternoon, event:, name: 'Afternoon Science',
                                            close_at: 1.day.from_now)
      create(:event_option, optionable: event)

      get time_slots_path(event: event.id, school: event.school_id)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(slot.name)

      get children_path(source: 'event', id: event.id)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(slot.name)
    end

    it 'shows departure extensions on the standalone afternoon attendance sheet' do
      slot = create(:time_slot, :afternoon, event:, start_time:, end_time: start_time + 3.hours)
      child = create(:internal_child)
      departure = slot.options.departure.first
      create(:invoice, event:, child:,
                       slot_regs_attributes: [{ child_id: child.id, registerable: slot }],
                       opt_regs_attributes: [{ child_id: child.id, registerable_type: 'Option',
                                               registerable_id: departure.id }])

      get children_path(source: 'time_slot', id: slot.id)

      expect(response).to have_http_status(:ok)
      html = Nokogiri::HTML(response.body)
      expect(html.at_css('#depart-header')).to be_present
      expect(html.at_css('td.depart').text).to include('05:30PM')
    end

    it 'keeps multi-school afternoon edits separate from same-name morning activities' do
      slot = create(:time_slot, :afternoon, event:, start_time:,
                                            end_time: start_time + 3.hours, name: 'Science')
      other_event = create(:event, name: event.name)
      afternoon = create(:time_slot, :afternoon, event: other_event, start_time:,
                                                 end_time: start_time + 3.hours, name: slot.name)
      morning = create(:time_slot, :morning, event: other_event,
                                             start_time: start_time - 4.hours,
                                             end_time: start_time - 1.hour, name: slot.name)

      patch time_slot_path(id: slot.id), params: {
        time_slot: { name: 'Updated Science', snack: '1',
                     target_school_ids: [other_event.school_id] }
      }

      expect(response).to have_http_status(:redirect)
      expect(afternoon.reload).to have_attributes(name: 'Updated Science', snack: true)
      expect(morning.reload.name).to eq('Science')
    end
  end

  context 'when registering a child' do
    let(:parent) { create(:customer) }
    let(:child) { create(:internal_child, parent:) }
    let!(:slot) do
      create(:time_slot, :afternoon, event:, name: 'Afternoon Science',
                                     start_time:, end_time: start_time + 3.hours,
                                     close_at: 1.day.from_now, snack: true)
    end

    before { sign_in parent }

    it 'shows the PM name, hours, snack, and departure options without a full-day switch' do
      get new_invoice_path(event_id: event.id, child: child.id)

      expect(response).to have_http_status(:ok)
      html = Nokogiri::HTML(response.body)
      expect(html.at_css("label[for='a_slot#{slot.id}']").text)
        .to include('Afternoon Science (午後)', '14:00–17:00')
      registration = html.at_css("[data-register-id-value='#{slot.id}']")
      expect(registration['data-register-snack-value']).to eq('true')
      expect(html.at_css("#a_slot#{slot.id}")).to be_present
      expect(html.at_css("#full#{slot.id}")).to be_nil
      expect(response.body).to include(slot.options.departure.first.name)
    end

    it 'does not add a snack charge for children who bring their own' do
      child.update!(own_snack: true)

      get new_invoice_path(event_id: event.id, child: child.id)

      html = Nokogiri::HTML(response.body)
      registration = html.at_css("[data-register-id-value='#{slot.id}']")
      expect(registration['data-register-snack-value']).to eq('false')
    end

    it 'keeps confirmed afternoon-only registrations visible' do
      create(:invoice, event:, child:, in_ss: true,
                       slot_regs_attributes: [{ child_id: child.id, registerable: slot }])

      get new_invoice_path(event_id: event.id, child: child.id)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Afternoon Science (午後): ◯')
    end

    it 'does not offer registration after the afternoon deadline' do
      slot.update!(close_at: 1.minute.ago)

      get new_invoice_path(event_id: event.id, child: child.id)

      expect(response).to have_http_status(:ok)
      expect(Nokogiri::HTML(response.body).at_css("#a_slot#{slot.id}")).to be_nil
    end
  end
end
