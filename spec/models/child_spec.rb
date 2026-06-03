# frozen_string_literal: true

require 'rails_helper'

describe Child do
  include ActiveSupport::Testing::TimeHelpers

  describe 'grade and kindy assignment from birthday' do
    before do
      travel_to Date.new(2026, 6, 3)
    end

    after do
      travel_back
    end

    it 'assigns elementary for manually added elementary-aged children' do
      child = build(:form_child, birthday: Date.new(2018, 4, 2), grade: nil)

      child.valid?

      expect(child.grade).to eq('小２')
      expect(child.kindy).to be(false)
    end

    it 'replaces the database default grade when no grade is submitted' do
      child = described_class.new(
        school: build(:school),
        allergies: 'なし',
        category: 'external',
        en_name: 'Brett Tanner',
        family_name: 'Tanner',
        first_name: 'Brett',
        kana_family: 'タナ',
        kana_first: 'ブレット',
        birthday: Date.new(2018, 4, 2),
        photos: 'OK'
      )

      child.valid?

      expect(child.grade).to eq('小２')
      expect(child.kindy).to be(false)
    end

    it 'keeps April 1 birthdays in the older school-year cohort' do
      child = build(:form_child, birthday: Date.new(2018, 4, 1), grade: nil)

      child.valid?

      expect(child.grade).to eq('小３')
      expect(child.kindy).to be(false)
    end

    it 'assigns kindy for kindergarten-aged children' do
      child = build(:form_child, birthday: Date.new(2021, 4, 2), grade: nil)

      child.valid?

      expect(child.grade).to eq('年中')
      expect(child.kindy).to be(true)
    end

    it 'does not override an explicitly supplied grade' do
      child = build(:form_child, birthday: Date.new(2018, 4, 2), grade: '年長')

      child.valid?

      expect(child.grade).to eq('年長')
      expect(child.kindy).to be(true)
    end
  end
end
