# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'an authorized user for InvoicePolicy' do
  it { is_expected.to authorize_action(:copy) }
  it { is_expected.to authorize_action(:merge) }
  it { is_expected.to authorize_action(:seen) }
  it { is_expected.to authorize_action(:confirm) }
  it { is_expected.to authorize_action(:confirmed) }

  it 'permits all attributes' do
    expect(subject).to permit_attributes(
      [:id, :child_id, :event_id, :in_ss, :entered, :email_sent,
       { slot_regs_attributes:
           %i[id child_id _destroy invoice_id registerable_id registerable_type],
         opt_regs_attributes:
           %i[id child_id _destroy invoice_id registerable_id registerable_type],
         coupons_attributes: [:code],
         adjustments_attributes: %i[id reason change invoice_id _destroy] }]
    )
  end
end

describe InvoicePolicy do
  subject(:policy) { described_class.new(user, invoice) }

  let(:invoice) { build(:invoice) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it_behaves_like 'fully authorized user'
    it_behaves_like 'an authorized user for InvoicePolicy'
  end

  context 'when area manager' do
    let(:user) { build(:area_manager) }

    it_behaves_like 'an authorized user for InvoicePolicy'
  end

  context 'when school manager' do
    let(:user) { build(:school_manager) }

    it_behaves_like 'an authorized user for InvoicePolicy'
  end

  context 'when statistician' do
    let(:user) { build(:statistician) }

    it_behaves_like 'unauthorized user'
  end

  context 'when parent of invoice child' do
    let(:user) { create(:customer) }

    before do
      user.children << invoice.child
      invoice.save
    end

    it_behaves_like 'authorized except destroy'
    it { is_expected.to authorize_action(:confirm) }
    it { is_expected.to authorize_action(:confirmed) }
    it { is_expected.to authorize_action(:copy) }
    it { is_expected.not_to authorize_action(:merge) }
    it { is_expected.not_to authorize_action(:seen) }

    it 'does not allow staff attributes' do
      expect(policy).to forbid_attributes(
        [:in_ss, :entered, :email_sent,
         { adjustments_attributes: %i[id reason change invoice_id _destroy] }]
      )
    end
  end

  context 'when parent of different child' do
    let(:user) { build(:customer) }

    it_behaves_like 'only authorized for new'
    it { is_expected.not_to authorize_action(:confirm) }
    it { is_expected.to authorize_action(:confirmed) }
    it { is_expected.not_to authorize_action(:copy) }
    it { is_expected.not_to authorize_action(:merge) }
    it { is_expected.not_to authorize_action(:seen) }

    it 'does not allow staff attributes' do
      expect(policy).to forbid_attributes(
        [:in_ss, :entered, :email_sent,
         { adjustments_attributes: %i[id reason change invoice_id _destroy] }]
      )
    end
  end

  context 'when resolving scopes' do
    let(:invoices) { create_list(:invoice, 3) }

    it 'resolves admin to all invoices' do
      user = build(:admin)
      expect(Pundit.policy_scope!(user, Invoice)).to match_array(invoices)
    end

    it 'resolves area_manager to area invoices' do
      user = create(:area_manager)
      user.managed_areas << create(:area)
      school = create(:school, area: user.managed_areas.first)
      event = create(:event, school:)
      area_invoices = create_list(:invoice, 2, event:)
      expect(Pundit.policy_scope!(user, Invoice)).to match_array(area_invoices)
    end

    it 'resolves school_manager to school invoices' do
      user = create(:school_manager)
      user.managed_schools << create(:school)
      event = create(:event, school: user.managed_schools.first)
      school_invoices = create_list(:invoice, 2, event:)
      expect(Pundit.policy_scope!(user, Invoice)).to match_array(school_invoices)
    end

    it 'resolves statistician to nothing' do
      user = build(:statistician)
      expect(Pundit.policy_scope!(user, Invoice)).to eq(Invoice.none)
    end

    it 'resolves parent of children to child invoices' do
      user = create(:customer)
      user.children << create_list(:child, 2, invoices: [create(:invoice)])
      expect(Pundit.policy_scope!(user, Invoice)).to match_array(user.invoices)
    end

    it 'resolves parent with no children to empty relation' do
      user = build(:customer)
      expect(Pundit.policy_scope!(user, Invoice)).to eq([])
    end
  end
end
