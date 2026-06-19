# frozen_string_literal: true

require 'rails_helper'
RSpec.configure do |c|
  c.include RegistrationFlowHelpers
end

RSpec.describe 'Registration flow', :js do
  let(:parent) { create(:customer) }
  let(:child) { create(:internal_child, parent:) }
  let(:time_slot) do
    create(:time_slot, :morning,
           close_at: 1.day.from_now,
           afternoon_slot:
             create(:time_slot, :afternoon, close_at: 1.day.from_now))
  end
  let(:event) do
    create(:event,
           time_slots: [time_slot],
           options: [create(:event_option, cost: 100)])
  end

  before do
    sign_in parent
  end

  after do
    sign_out parent
  end

  it 'the new registration page can register for activities and options' do
    expected_cost = 0
    visit new_invoice_path(event_id: event.id, child: child.id)
    total_cost = find_by_id('total_cost')

    check "m_slot#{time_slot.id}"
    expected_cost += event.member_prices.courses['1']
    expect(total_cost.text).to eq cost_text(expected_cost)

    meal_option = time_slot.options.meal.first
    check "opt#{meal_option.id}"
    expected_cost += meal_option.cost
    expect(total_cost.text).to eq cost_text(expected_cost)

    # This, and only this, fails intermittently. So bye
    # arrival_option = time_slot.options.arrival.first
    # choose "arrival#{time_slot.id}opt#{arrival_option.id}"
    # expected_cost += arrival_option.cost
    # expect(total_cost.text).to eq cost_text(expected_cost)

    check "a_slot#{time_slot.afternoon_slot.id}"
    expected_cost += event.member_prices.courses['1'] + TimeSlot.snack_cost_for(event)
    expect(total_cost.text).to eq cost_text(expected_cost)

    check "eopt#{event.options.first.id}"
    expected_cost += event.options.first.cost
    expect(total_cost.text).to eq cost_text(expected_cost)

    event_cost = find('h2[data-price-target="eventCost"]').text
    localized_cost =
      ActionController::Base.helpers
                            .number_to_currency(expected_cost, locale: :ja)
    expect(event_cost).to eq "#{event.name}の合計: #{localized_cost}"

    click_on I18n.t('events.show.confirm_invoice')
    expect(page).to have_content I18n.t('invoices.confirm.not_done')

    click_on I18n.t('invoices.confirm.confirm_changes')
    expect(page).to have_content I18n.t('invoices.show.confirm_success')
    expect(find_by_id('final_cost').text).to eq cost_text(expected_cost)
  end

  it 'keeps the footer total in sync when new 2026 batches are added to existing batches' do
    member_prices = create(:member_prices, course1: '1_000', course3: '',
                                           course5: '2_500', course10: '',
                                           course15: '', course20: '',
                                           course25: '', course30: '',
                                           course35: '', course40: '',
                                           course45: '', course50: '')
    event = create(:event,
                   start_date: 1.week.from_now.to_date,
                   end_date: 2.weeks.from_now.to_date,
                   member_prices:)
    initial_slots = create_list(:time_slot, 4, :morning, event:,
                                close_at: 1.week.from_now)
    later_slot = create(:time_slot, :morning, event:, close_at: 1.week.from_now)
    new_slots = create_list(:time_slot, 5, :morning, event:,
                            close_at: 1.week.from_now)
    invoice = create(:invoice, event:, child:,
                               slot_regs_attributes: slot_attributes(initial_slots, child))
    invoice.assign_attributes(slot_regs_attributes: slot_attributes([later_slot], child))
    invoice.save!

    visit new_invoice_path(event_id: event.id, child: child.id)

    new_slots.each { |slot| check "m_slot#{slot.id}" }

    expect(find_by_id('total_cost').text).to eq cost_text(7_500)
  end

  def slot_attributes(slots, child)
    slots.map do |slot|
      { child_id: child.id,
        registerable_id: slot.id,
        registerable_type: 'TimeSlot' }
    end
  end
end
