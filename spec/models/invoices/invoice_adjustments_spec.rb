# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice do
  let(:event) { create(:event) }

  def find_adjustment(invoice)
    invoice.adjustments.find do |adj|
      adj.change == change && adj.reason == reason
    end
  end

  context 'when considering hat adjustment' do
    let(:change) { 1_100 }
    let(:reason) { '帽子代(野外アクティビティに参加される方でKids UP帽子をお持ちでない方のみ)' }
    let(:valid_hat_invoice) do
      child = build(:child, category: :external, received_hat: false)
      invoice = build(:invoice, event:, child:, slot_regs:
                        [build(:slot_reg, child:, registerable:
                                 create(:time_slot, category: 'outdoor'))])
      invoice
    end

    it 'applies if external kid with no hat & registered for outdoor' do
      valid_hat_invoice.calc_cost
      hat_adj = find_adjustment(valid_hat_invoice)
      expect(hat_adj).to be_present
    end

    it 'does not apply if internal kid' do
      valid_hat_invoice.child = build(:child, category: :internal, received_hat: false)
      valid_hat_invoice.calc_cost
      hat_adj = find_adjustment(valid_hat_invoice)
      expect(hat_adj).to be_nil
    end

    it 'does not apply if not registered for outdoor' do
      valid_hat_invoice.slot_regs = [
        build(:slot_reg,
              child: valid_hat_invoice.child,
              registerable: build(:time_slot, category: 'seasonal'))
      ]
      valid_hat_invoice.calc_cost
      hat_adj = find_adjustment(valid_hat_invoice)
      expect(hat_adj).to be_nil
    end

    it 'does not apply if kid received hat' do
      valid_hat_invoice.child = build(:child, category: :external, received_hat: true)
      valid_hat_invoice.calc_cost
      hat_adj = find_adjustment(valid_hat_invoice)
      expect(hat_adj).to be_nil
    end

    it 'does not apply if identical adjustment already exists' do
      valid_hat_invoice.calc_cost
      valid_hat_invoice.calc_cost
      hat_adjs = valid_hat_invoice.adjustments.select do |adj|
        adj.change == change && adj.reason == reason
      end
      expect(hat_adjs.size).to eq(1)
    end
  end

  context 'when considering first time adjustment' do
    let(:change) { 1_100 }
    let(:reason) { '初回登録料(初めてシーズナルスクールに参加する非会員の方)' }
    let(:valid_first_time_invoice) do
      child = build(:child, category: :external, first_seasonal: true)
      invoice = build(:invoice, event:, child:, slot_regs:
                        [build(:slot_reg, child:, registerable: create(:time_slot))])
      invoice
    end

    it 'applies if external kid attending first seasonal and non-zero regs' do
      valid_first_time_invoice.calc_cost
      first_time_adj = find_adjustment(valid_first_time_invoice)
      expect(first_time_adj).to be_present
    end

    it 'does not apply if kid is internal' do
      valid_first_time_invoice.child = build(:child, category: :internal)
      valid_first_time_invoice.calc_cost
      first_time_adj = find_adjustment(valid_first_time_invoice)
      expect(first_time_adj).to be_nil
    end

    it 'does not apply if no first seasonal' do
      valid_first_time_invoice.child = build(:child, category: :external, first_seasonal: false)
      valid_first_time_invoice.calc_cost
      first_time_adj = find_adjustment(valid_first_time_invoice)
      expect(first_time_adj).to be_nil
    end

    it 'does not apply if no registrations' do
      valid_first_time_invoice.slot_regs = []
      valid_first_time_invoice.calc_cost
      first_time_adj = find_adjustment(valid_first_time_invoice)
      expect(first_time_adj).to be_nil
    end

    it 'does not apply if identical adjustment already exists' do
      valid_first_time_invoice.calc_cost
      valid_first_time_invoice.calc_cost
      first_time_adjs = valid_first_time_invoice.adjustments.select do |adj|
        adj.change == change && adj.reason == reason
      end
      expect(first_time_adjs.size).to eq(1)
    end
  end

  context 'when considering repeater discount' do
    let(:change) { -10_000 }
    let(:reason) { '非会員リピーター割引(以前シーズナルスクールに参加された非会員の方)' }
    let(:valid_repeater_invoice) do
      child = build(:child, category: :external, first_seasonal: false)
      invoice = build(:invoice, event:, child:, slot_regs:
                        time_slots.map { |s| build(:slot_reg, child:, registerable: s) })
      invoice
    end
    let(:time_slots) { create_list(:time_slot, 5) }

    it 'applies if external kid not attending first seasonal and >= 5 activity regs' do
      valid_repeater_invoice.calc_cost
      repeater_adj = find_adjustment(valid_repeater_invoice)
      expect(repeater_adj).to be_present
    end

    it 'does not apply if kid is internal' do
      valid_repeater_invoice.child = build(:child, category: :internal)
      valid_repeater_invoice.calc_cost
      repeater_adj = find_adjustment(valid_repeater_invoice)
      expect(repeater_adj).to be_nil
    end

    it 'does not apply if first seasonal' do
      valid_repeater_invoice.child = build(:child, category: :external, first_seasonal: true)
      valid_repeater_invoice.calc_cost
      repeater_adj = find_adjustment(valid_repeater_invoice)
      expect(repeater_adj).to be_nil
    end

    it 'does not apply if < 5 activity regs' do
      valid_repeater_invoice.slot_regs = build_list(:slot_reg, 4,
                                                    child: valid_repeater_invoice.child)
      valid_repeater_invoice.calc_cost
      repeater_adj = find_adjustment(valid_repeater_invoice)
      expect(repeater_adj).to be_nil
    end

    it 'does not apply if identical adjustment already exists' do
      valid_repeater_invoice.calc_cost
      valid_repeater_invoice.calc_cost
      repeater_adjs = valid_repeater_invoice.adjustments.select do |adj|
        adj.change == change && adj.reason == reason
      end
      expect(repeater_adjs.size).to eq(1)
    end

    it 'does not apply if applied to other invoice for same event' do
      create(:invoice, child: valid_repeater_invoice.child, event:, adjustments:
               [create(:adjustment, change:, reason:)])
      valid_repeater_invoice.calc_cost
      expect(find_adjustment(valid_repeater_invoice)).to be_nil
    end

    it 'applies if applied to invoice for other event' do
      create(:invoice, child: valid_repeater_invoice.child, event: create(:event), adjustments:
               [create(:adjustment, change:, reason:)])
      valid_repeater_invoice.calc_cost
      expect(find_adjustment(valid_repeater_invoice)).to be_present
    end
  end

  context 'when considering early bird discount' do
    let(:change) { -1_000 }
    let(:reason) { '早割' }
    let(:valid_early_invoice) do
      child = build(:child, category: :external)
      invoice = build(:invoice, event:, child:, slot_regs:
                        [build(:slot_reg, child:, registerable: create(:time_slot))])
      invoice
    end

    before do
      event.update(early_bird_discount: change,
                   start_date: Time.zone.today)
    end

    it 'applies if before early bird date' do
      event.update(early_bird_date: 7.days.from_now)
      valid_early_invoice.calc_cost
      early_adj = find_adjustment(valid_early_invoice)
      expect(early_adj).to be_present
    end

    it 'does not apply if after early bird date' do
      event.update(early_bird_date: 7.days.ago)
      valid_early_invoice.calc_cost
      early_adj = find_adjustment(valid_early_invoice)
      expect(early_adj).to be_nil
    end

    it 'remains applied if invoice modified after early bird date' do
      event.update(early_bird_date: 7.days.from_now)
      valid_early_invoice.calc_cost
      event.update(early_bird_date: 7.days.ago)
      valid_early_invoice.calc_cost
      early_adj = find_adjustment(valid_early_invoice)
      expect(early_adj).to be_present
    end

    it 'applies if applied to invoice for other event' do
      event.update(early_bird_date: 7.days.from_now)
      create(:invoice, child: valid_early_invoice.child, event: create(:event), adjustments:
               [create(:adjustment, change:, reason:)])
      valid_early_invoice.calc_cost
      expect(find_adjustment(valid_early_invoice)).to be_present
    end

    it 'applies once for each party attended' do
      event.update(early_bird_date: 7.days.from_now)
      valid_early_invoice.slot_regs += [build(:slot_reg, child: valid_early_invoice.child,
                                                         registerable: create(:time_slot))]
      valid_early_invoice.calc_cost
      early_bird_count = valid_early_invoice.adjustments.count { |adj| adj.reason == '早割' }
      expect(early_bird_count).to eq(2)
    end
  end
end
