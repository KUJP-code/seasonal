# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsHelper, type: :helper do
  include ActiveSupport::Testing::TimeHelpers

  describe '#show_science_2026?' do
    let(:school) { create(:school, id: school_id, name: school_name) }
    let(:child) { create(:child, school:, school_id:) }

    after { travel_back }

    context 'with a Saturday school' do
      let(:school_id) { 6 }
      let(:school_name) { '東陽町' }

      it 'shows from May 10 through July 4' do
        travel_to Date.new(2026, 5, 10)

        expect(helper.show_science_2026?(child)).to be(true)
        expect(helper.science_2026_date(child)).to eq(Date.new(2026, 7, 4))
        expect(helper.science_2026_image_path(child)).to include('2026-science-4th')
      end

      it 'hides after July 4' do
        travel_to Date.new(2026, 7, 5)

        expect(helper.show_science_2026?(child)).to be(false)
      end
    end

    context 'with a Sunday school' do
      let(:school_id) { 7 }
      let(:school_name) { '長原' }

      it 'shows through July 5' do
        travel_to Date.new(2026, 7, 5)

        expect(helper.show_science_2026?(child)).to be(true)
        expect(helper.science_2026_date(child)).to eq(Date.new(2026, 7, 5))
        expect(helper.science_2026_image_path(child)).to include('2026-science-5th')
      end

      it 'hides after July 5' do
        travel_to Date.new(2026, 7, 6)

        expect(helper.show_science_2026?(child)).to be(false)
      end
    end
  end
end
