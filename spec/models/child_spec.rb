# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Child do
  let(:child_attr) { attributes_for(:child) }
  let(:valid_child) { build(:child) }
  let(:child) { create(:child) }

  context 'when valid' do
    it 'saves' do
      valid = valid_child.save!
      expect(valid).to be true
    end

    it 'saves level as unknown by default' do
      lvl = child.level
      expect(lvl).to eq 'unknown'
    end

    it 'can change its level' do
      child.level = 'sky_hi'
      lvl = child.level
      expect(lvl).to eq 'sky_hi'
    end
  end

  context 'when invalid' do
    context 'when birthday invalid' do
      it 'rejects children who are too old' do
        old_child = build(:child, birthday: 20.years.ago)
        valid = old_child.save
        expect(valid).to be false
      end

      it 'rejects children who are too young' do
        young_child = build(:child, birthday: 1.year.ago)
        valid = young_child.save
        expect(valid).to be false
      end
    end
  end

  context 'with parent' do
    let(:parent) { create(:customer_user) }

    it 'knows its parent' do
      new_child = create(:child, parent: parent)
      childs_parent = new_child.parent
      expect(childs_parent).to eq parent
    end

    it 'parent knows its child' do
      new_child = create(:child, parent: parent)
      parent_children = parent.children
      expect(parent_children).to include(new_child)
    end
  end

  context 'with school' do
    let(:school) { create(:school) }

    it 'knows its school' do
      new_child = create(:child, school: school)
      childs_school = new_child.school
      expect(childs_school).to eq school
    end

    it 'school knows its student' do
      new_child = create(:child, school: school)
      school_children = school.children
      expect(school_children).to include(new_child)
    end

    it 'causes an error when school deletion attempted' do
      school.children.create(child_attr)
      expect { school.destroy }.to raise_error(ActiveRecord::InvalidForeignKey)
    end

    context 'when changing schools' do
      let(:change_child) { create(:child, school: school) }

      it 'can change schools' do
        new_school = create(:school)
        new_school.children << change_child
        new_school_children = new_school.children
        expect(new_school_children).to include(change_child)
      end

      it 'does not remain associated with the old school' do
        new_school = create(:school)
        new_school.children << change_child
        old_school_children = school.children
        expect(old_school_children).not_to include(change_child)
      end
    end
  end

  context 'with area through school' do
    let(:area) { create(:area) }
    let(:school) { area.schools.create(attributes_for(:school)) }

    it 'knows its area' do
      new_child = school.children.create(attributes_for(:child))
      child_area = new_child.area
      expect(child_area).to eq area
    end

    it 'area knows its children' do
      new_child = school.children.create(attributes_for(:child))
      area_children = area.children
      expect(area_children).to include(new_child)
    end
  end

  context 'with events' do
    xit "knows which events it's attending" do
    end

    xit "knows which events it's registered for but not attending" do
    end

    xit 'knows which events it has attended' do
    end

    xit 'knows which events it will attend' do
    end

    xit "knows which events it's attending at different schools" do
    end
  end

  context 'with time_slots' do
    xit 'knows which time slots its attending' do
    end

    xit "knows which time slots at its school it isn't attending" do
    end
  end
end
