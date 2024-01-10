# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'staff for InquiryPolicy' do
  before do
    give_managers_access(user)
  end

  it { is_expected.to authorize_action(:index) }
  it { is_expected.to authorize_action(:new) }
  it { is_expected.to authorize_action(:edit) }
  it { is_expected.to authorize_action(:create) }
  it { is_expected.to authorize_action(:update) }
  it { is_expected.to authorize_action(:destroy) }
end

def give_managers_access(user)
  if user.area_manager?
    user.managed_areas << inquiry.area
    user.save
  elsif user.school_manager?
    user.managed_schools << inquiry.school
    user.save
  end
end

RSpec.shared_examples 'unauthorized user for InquiryPolicy' do
  it { is_expected.not_to authorize_action(:index) }
  it { is_expected.not_to authorize_action(:new) }
  it { is_expected.not_to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:update) }
  it { is_expected.not_to authorize_action(:destroy) }
end

describe InquiryPolicy do
  subject(:policy) { described_class.new(user, inquiry) }

  let(:inquiry) { create(:inquiry) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it_behaves_like 'staff for InquiryPolicy'
  end

  context 'when area manager' do
    let(:user) { build(:area_manager) }

    it_behaves_like 'staff for InquiryPolicy'

    context "when not manager of the inquiry's area" do
      before do
        user.managed_areas = []
      end

      it { is_expected.not_to authorize_action(:edit) }
      it { is_expected.not_to authorize_action(:update) }
    end
  end

  context 'when school manager' do
    let(:user) { build(:school_manager) }

    it_behaves_like 'staff for InquiryPolicy'

    context "when not manager of the inquiry's school" do
      before do
        user.managed_schools = []
      end

      it { is_expected.not_to authorize_action(:edit) }
      it { is_expected.not_to authorize_action(:update) }
    end
  end

  context 'when statistician' do
    let(:user) { build(:statistician) }

    it_behaves_like 'unauthorized user for InquiryPolicy'
  end

  context 'when customer' do
    let(:user) { build(:customer) }

    it_behaves_like 'unauthorized user for InquiryPolicy'
  end

  context 'when resolving scopes' do
    let(:inquiries) { create_list(:inquiry, 3) }

    it 'resolves admin to all inquiries' do
      user = build(:admin)
      expect(Pundit.policy_scope!(user, Inquiry.all)).to eq(inquiries)
    end

    it 'resolves area_manager to inquiries of area' do
      user = create(:area_manager)
      user.managed_areas << create(:area)
      area_school = create(:school, area: user.managed_areas.first)
      area_inquiries = create_list(:inquiry, 2, school: area_school)
      expect(Pundit.policy_scope!(user, Inquiry.all)).to eq(area_inquiries)
    end

    it 'resolves school_manager to inquiries of school' do
      user = create(:school_manager)
      user.managed_schools << create(:school)
      school_inquiries = create_list(:inquiry, 2, school: user.managed_schools.first)
      expect(Pundit.policy_scope!(user, Inquiry.all)).to eq(school_inquiries)
    end

    it 'resolves statistician to all inquiries' do
      user = create(:statistician)
      expect(Pundit.policy_scope!(user, Inquiry)).to eq(Inquiry.all)
    end

    it 'resolves customer to nothing' do
      user = build(:customer)
      expect(Pundit.policy_scope!(user, Inquiry.all)).to eq(Inquiry.none)
    end
  end
end
