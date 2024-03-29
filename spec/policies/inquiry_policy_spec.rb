# frozen_string_literal: true

require 'rails_helper'

describe InquiryPolicy do
  subject(:policy) { described_class.new(user, inquiry) }

  let(:inquiry) { build(:inquiry) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it_behaves_like 'fully authorized user'
  end

  context 'when area manager' do
    context 'when manager of inquiry area' do
      let(:user) { create(:area_manager) }

      before do
        user.managed_areas << inquiry.area
      end

      it_behaves_like 'fully authorized user'
    end

    context "when not manager of the inquiry's area" do
      let(:user) { build(:area_manager) }

      it_behaves_like 'only authorized for new'
    end
  end

  context 'when school manager' do
    context 'when manager of inquiry school' do
      let(:user) { create(:school_manager) }

      before do
        user.managed_schools << inquiry.school
        inquiry.save
      end

      it_behaves_like 'fully authorized user'
    end

    context "when not manager of the inquiry's school" do
      let(:user) { build(:school_manager) }

      it_behaves_like 'only authorized for new'
    end
  end

  context 'when statistician' do
    let(:user) { build(:statistician) }

    it_behaves_like 'unauthorized user'
  end

  context 'when customer' do
    let(:user) { build(:customer) }

    it_behaves_like 'unauthorized user'
  end

  context 'when resolving scopes' do
    let(:inquiries) { create_list(:inquiry, 3) }

    it 'resolves admin to all inquiries' do
      user = build(:admin)
      expect(Pundit.policy_scope!(user, Inquiry)).to eq(inquiries)
    end

    it 'resolves area_manager to inquiries of area' do
      user = create(:area_manager)
      user.managed_areas << create(:area)
      area_school = create(:school, area: user.managed_areas.first)
      area_inquiries = create_list(:inquiry, 2, school: area_school)
      expect(Pundit.policy_scope!(user, Inquiry)).to eq(area_inquiries)
    end

    it 'resolves school_manager to inquiries of school' do
      user = create(:school_manager)
      user.managed_schools << create(:school)
      school_inquiries = create_list(:inquiry, 2, school: user.managed_schools.first)
      expect(Pundit.policy_scope!(user, Inquiry)).to eq(school_inquiries)
    end

    it 'resolves statistician to all inquiries' do
      user = build(:statistician)
      expect(Pundit.policy_scope!(user, Inquiry)).to eq(Inquiry.all)
    end

    it 'resolves customer to nothing' do
      user = build(:customer)
      expect(Pundit.policy_scope!(user, Inquiry)).to eq(Inquiry.none)
    end
  end
end
