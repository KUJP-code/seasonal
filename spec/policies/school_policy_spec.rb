# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'manager of school for SchoolPolicy' do
  it { is_expected.to authorize_action(:show) }
  it { is_expected.not_to authorize_action(:new) }
  it { is_expected.to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.to authorize_action(:update) }
  it { is_expected.not_to authorize_action(:destroy) }

  it 'permits basic attributes' do
    expect(subject).to permit_attributes(
      %i[name address phone nearby_stations bus_areas image_id email nearby_schools]
    )
  end

  it 'does not permit management/area attributes' do
    expect(subject).to forbid_attributes(%i[area_id managements_attributes])
  end
end

RSpec.describe SchoolPolicy do
  subject(:policy) { described_class.new(user, school) }

  let(:school) { build(:school) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it_behaves_like 'fully authorized user'

    it 'permits all attributes' do
      expect(policy).to permit_attributes(
        [:name, :address, :phone, :nearby_stations, :bus_areas, :image_id, :email,
         :nearby_schools, :area_id,
         { managements_attributes:
            %i[id manageable_id manageable_type manager_id _destroy] }]
      )
    end
  end

  context 'when area manager' do
    let(:user) { build(:area_manager) }

    context "when manager of school's area" do
      before do
        user.managed_areas << school.area
        school.save && user.save
      end

      it_behaves_like 'manager of school for SchoolPolicy'
    end

    context 'when manager of different area' do
      it_behaves_like 'unauthorized user'
    end
  end

  context 'when school manager' do
    let(:user) { build(:school_manager) }

    context 'when manager of school' do
      before do
        user.managed_schools << school
        user.save
      end

      it_behaves_like 'manager of school for SchoolPolicy'
    end

    context 'when manager of different school' do
      it_behaves_like 'unauthorized user'
    end
  end

  context 'when statistician' do
    let(:user) { build(:statistician) }

    it_behaves_like 'viewer'
  end

  context 'when customer' do
    let(:user) { build(:customer) }

    it_behaves_like 'unauthorized user'
  end

  context 'when resolving scope' do
    let(:schools) { create_list(:school, 3) }

    it 'resolves admin to all non-test schools' do
      user = build(:admin)
      expect(Pundit.policy_scope!(user, School)).to eq(schools)
    end

    it 'resolves area_manager to area schools' do
      user = create(:area_manager)
      user.managed_areas << create(:area)
      area_schools = create_list(:school, 2, area: user.managed_areas.first)
      expect(Pundit.policy_scope!(user, School)).to eq(area_schools)
    end

    it 'resolves school_manager to school' do
      user = create(:school_manager)
      user.managed_schools << create(:school)
      expect(Pundit.policy_scope!(user, School)).to eq(user.managed_schools)
    end

    it 'resolves statistician to all schools' do
      user = build(:statistician)
      expect(Pundit.policy_scope!(user, School)).to eq(schools)
    end

    it 'resolves customer to nothing' do
      user = build(:customer)
      expect(Pundit.policy_scope!(user, School)).to be_empty
    end
  end
end
