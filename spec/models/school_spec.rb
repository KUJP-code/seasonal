# frozen_string_literal: true

require 'rails_helper'

RSpec.describe School do
  subject(:school) { create(:school) }

  it { is_expected.to be_valid }

  context 'when fetching setsumeikais' do
    it 'excludes setsumeikais with future release date' do
      setsumeikai = create(
        :setsumeikai,
        release_date: 1.day.from_now,
        start: 2.days.from_now
      )
      school.involved_setsumeikais << setsumeikai
      expect(school.calendar_setsumeikais).not_to include(setsumeikai)
    end

    it 'returns setsumeikais whose release date is today' do
      setsumeikai = create(
        :setsumeikai,
        release_date: Time.zone.today,
        start: 2.days.from_now
      )
      school.involved_setsumeikais << setsumeikai
      expect(school.calendar_setsumeikais).to include(setsumeikai)
    end

    it 'returns setsumeikais whose release date passed' do
      setsumeikai = create(
        :setsumeikai,
        release_date: 1.day.ago,
        start: 2.days.from_now
      )
      school.involved_setsumeikais << setsumeikai
      expect(school.calendar_setsumeikais).to include(setsumeikai)
    end
  end
end
