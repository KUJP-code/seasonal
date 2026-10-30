# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChildrenHelper do
  describe '#monthly_regular_days' do
    include ActiveSupport::Testing::TimeHelpers

    let(:child) { create(:internal_child) }
    let(:event) do
      build(:event, start_date: Date.new(2027, 1, 1), end_date: Date.new(2027, 2, 28))
    end

    %i[external reservation unknown].each do |category|
      it "hides recorded weekdays for #{category} students" do
        child.update!(category:)
        create(:regular_schedule, child:, month: Date.new(2026, 12, 1), monday: true)

        expect(helper.monthly_regular_days(child)).to eq('')
        expect(helper.monthly_regular_days(child, events: [event])).to eq('')
      end
    end

    it 'shows only the latest weekdays applicable to the event' do
      create(:regular_schedule, child:, month: Date.new(2026, 12, 1), monday: true)
      create(:regular_schedule, child:, month: Date.new(2027, 2, 1), tuesday: true)
      create(:regular_schedule, child:, month: Date.new(2027, 3, 1), friday: true)

      I18n.with_locale(:ja) do
        expect(helper.monthly_regular_days(child, events: [event]))
          .to eq('火')
      end
    end

    it 'shows only the latest uploaded weekdays on student information' do
      create(:regular_schedule, child:, month: Date.new(2026, 12, 1), monday: true)
      create(:regular_schedule, child:, month: Date.new(2027, 2, 1), tuesday: true)

      travel_to Date.new(2027, 1, 4) do
        I18n.with_locale(:ja) do
          expect(helper.monthly_regular_days(child)).to eq('火')
        end
      end
    end

    it 'shows November weekdays on student information before November starts' do
      create(:regular_schedule, child:, month: Date.new(2026, 11, 1),
                                monday: true, wednesday: true, friday: true)

      travel_to Date.new(2026, 10, 30) do
        expect(helper.monthly_regular_days(child)).to eq('月・水・金')
      end
    end

    it 'shows a carried-forward schedule only once across all event months' do
      event.start_date = Date.new(2026, 12, 1)
      create(:regular_schedule, child:, month: Date.new(2026, 11, 1),
                                monday: true, wednesday: true, friday: true)

      expect(helper.monthly_regular_days(child, events: [event])).to eq('月・水・金')
    end

    it 'does not repeat identical weekdays from separate monthly uploads' do
      create(:regular_schedule, child:, month: Date.new(2027, 1, 1), monday: true)
      create(:regular_schedule, child:, month: Date.new(2027, 2, 1), monday: true)

      expect(helper.monthly_regular_days(child, events: [event])).to eq('月')
    end

    it 'shows only the final pattern when weekdays change during the event' do
      event.start_date = Date.new(2026, 12, 1)
      create(:regular_schedule, child:, month: Date.new(2026, 12, 1), monday: true)
      create(:regular_schedule, child:, month: Date.new(2027, 1, 1), tuesday: true)
      create(:regular_schedule, child:, month: Date.new(2027, 2, 1), monday: true)

      expect(helper.monthly_regular_days(child, events: [event])).to eq('月')
    end

    it 'does not display expired schedules or borrow from a future month' do
      create(:regular_schedule, child:, month: Date.new(2026, 7, 1), monday: true)
      create(:regular_schedule, child:, month: Date.new(2027, 3, 1), tuesday: true)

      expect(helper.monthly_regular_days(child, events: [event])).to eq('')
    end

    it 'shows an explicit no-days schedule instead of older weekdays' do
      create(:regular_schedule, child:, month: Date.new(2026, 12, 1), monday: true)
      create(:regular_schedule, child:, month: Date.new(2027, 1, 1))

      I18n.with_locale(:ja) do
        expect(helper.monthly_regular_days(child, events: [event]))
          .to eq('—')
      end
    end
  end

  describe 'name splitting helpers' do
    let(:child) do
      build(:child, name: '廣田　快斗', katakana_name: 'ヒロタ　カイト')
    end

    it 'splits names on full-width spaces' do
      expect(helper.family_name(child)).to eq('廣田')
      expect(helper.first_name(child)).to eq('快斗')
      expect(helper.kana_family(child)).to eq('ヒロタ')
      expect(helper.kana_first(child)).to eq('カイト')
    end

    it 'does not duplicate single-token names into both fields' do
      child.name = '廣田快斗'
      child.katakana_name = 'ヒロタカイト'

      expect(helper.family_name(child)).to eq('廣田快斗')
      expect(helper.first_name(child)).to eq('')
      expect(helper.kana_family(child)).to eq('ヒロタカイト')
      expect(helper.kana_first(child)).to eq('')
    end
  end
end
