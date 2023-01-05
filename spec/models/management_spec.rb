# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Management do
  context 'when valid' do
    it 'saves area management' do
      area_management = create(:area_management)
      valid = area_management.save!
      expect(valid).to be true
    end

    it 'saves school management' do
      school_management = create(:school_management)
      valid = school_management.save!
      expect(valid).to be true
    end
  end

  context 'with area_manager' do
    subject(:area_management) { create(:management, manager: am, manageable: area) }

    let(:area) { create(:area) }
    let(:am) { create(:am_user) }

    it 'knows the area manager' do
      area_manager = area_management.manager
      expect(area_manager).to eq am
    end

    it 'knows the managed area' do
      managed_area = area_management.manageable
      expect(managed_area).to eq area
    end

    it 'is destroyed when manager destroyed' do
      area_management
      expect { am.destroy }.to \
        change(described_class, :count)
        .by(-1)
    end

    it 'is destroyed when area destroyed' do
      area_management
      expect { area.destroy }.to \
        change(described_class, :count)
        .by(-1)
    end
  end

  context 'with school manager' do
    subject(:school_management) { create(:management, manager: sm, manageable: school) }

    let(:school) { create(:school) }
    let(:sm) { create(:sm_user) }

    it 'knows the school manager' do
      school_manager = school_management.manager
      expect(school_manager).to eq sm
    end

    it 'knows the managed school' do
      managed_school = school_management.manageable
      expect(managed_school).to eq school
    end

    it 'is destroyed when manager destroyed' do
      school_management
      expect { sm.destroy }.to \
        change(described_class, :count)
        .by(-1)
    end

    it 'is destroyed when school destroyed' do
      school_management
      expect { school.destroy }.to \
        change(described_class, :count)
        .by(-1)
    end
  end
end
