# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Child do
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
    let(:child_attr) { attributes_for(:child) }
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

  context 'with registrations' do
    let(:event) { create(:event, school: child.school) }
    let(:time_slot) { create(:time_slot, event: event) }
    let(:registration) { create(:slot_registration, child: child, registerable: time_slot) }

    it 'knows its registered time slot' do
      regsitered_slot = registration.registerable
      expect(regsitered_slot).to eq time_slot
    end

    it 'registration cost matches time slot cost' do
      reg_cost = registration.cost
      slot_cost = time_slot.cost
      expect(reg_cost).to eq slot_cost
    end

    it 'registration cost can be discounted without affecting slot cost' do
      registration.cost = 0
      slot_cost = time_slot.cost
      expect(slot_cost).not_to eq 0
    end

    it 'deletes its registrations when deleted' do
      registration
      expect { child.destroy }.to \
        change(Registration, :count)
        .by(-1)
    end

    context 'with time_slots through registrations' do
      it "knows which time slots it's attending" do
        time_slot.registrations.create(child: child, cost: time_slot.cost)
        attending_list = child.time_slots
        expect(attending_list).to include(time_slot)
      end
    end

    context 'with events through time slots' do
      it "knows which events it's attending" do
        child.registrations.create(registerable: time_slot, cost: time_slot.cost)
        child_events = child.events
        expect(child_events).to include(event)
      end

      # TODO: must be a cleaner way to write this
      it "knows which events it's attending at different schools" do
        diff_school_event = create(:event)
        diff_school_slot = create(:time_slot, event: diff_school_event)
        diff_school_slot.registrations.create(child: child)
        diff_school_events = child.diff_school_events
        expect(diff_school_events).to contain_exactly(diff_school_event)
      end
    end

    context 'with options through registrations' do
      subject(:option) { create(:option) }

      it 'knows its registered options' do
        child.registrations.create(registerable: option)
        child_options = child.options
        expect(child_options).to include(option)
      end

      it "doesn't destroy options when destroyed" do
        child.registrations.create(registerable: option)
        expect { child.destroy }.not_to change(Option, :count)
      end
    end
  end
end
