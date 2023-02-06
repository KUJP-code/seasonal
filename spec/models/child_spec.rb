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

    it 'saves category as internal by default' do
      category = child.category
      expect(category).to eq 'internal'
    end

    it 'saves without ssid' do
      valid_child.ssid = nil
      valid = valid_child.save!
      expect(valid).to be true
    end

    it 'saves with valid katakana name' do
      valid_child.katakana_name = 'タナカ　サクラ'
      valid = valid_child.save!
      expect(valid).to be true
    end

    it 'can change its level' do
      child.level = :sky_high
      lvl = child.level
      expect(lvl).to eq 'sky_high'
    end

    with_versioning do
      it 'creates a paper trail on create' do
        valid_child.save
        expect(valid_child).to be_versioned
      end

      it 'creates a paper trail on update' do
        child.update(en_name: 'Brittaney')
        expect(child).to be_versioned
      end

      it 'creates a paper trail on destroy' do
        child.destroy
        expect(child).to be_versioned
      end

      it 'can be restored to previous version' do
        old_name = child.en_name
        child.update(en_name: 'Brittaney')
        child.paper_trail.previous_version.save
        reverted_name = child.reload.en_name
        expect(old_name).to eq reverted_name
      end

      it 'can be restored after destruction (if password specified)' do
        child.destroy
        restored = child.versions.last.reify.save!
        expect(restored).to be true
      end
    end
  end

  context 'when invalid' do
    context 'when required fields missing' do
      it 'Japanese first name missing' do
        valid_child.ja_first_name = nil
        valid = valid_child.save
        expect(valid).to be false
      end

      it 'Japanese family name missing' do
        valid_child.ja_family_name = nil
        valid = valid_child.save
        expect(valid).to be false
      end

      it 'Katakana name missing' do
        valid_child.katakana_name = nil
        valid = valid_child.save
        expect(valid).to be false
      end

      it 'English name missing' do
        valid_child.en_name = nil
        valid = valid_child.save
        expect(valid).to be false
      end
    end

    context 'when birthday invalid' do
      it 'rejects children who are too old' do
        old_child = build(:child, birthday: 20.years.ago)
        valid = old_child.save
        expect(valid).to be false
      end

      it 'rejects children who are too young' do
        young_child = build(:child, birthday: 6.months.ago)
        valid = young_child.save
        expect(valid).to be false
      end
    end

    context 'when names in wrong language' do
      it 'rejects Japanese first name in English' do
        valid_child.ja_first_name = "B'rett-Tan ner"
        valid = valid_child.save
        expect(valid).to be false
      end

      it 'rejects Japanese family name in English' do
        valid_child.ja_family_name = "B'rett-Tan ner"
        valid = valid_child.save
        expect(valid).to be false
      end

      it 'rejects Katakana name in Kanji' do
        valid_child.katakana_name = '吉田'
        valid = valid_child.save
        expect(valid).to be false
      end

      it 'rejects Katakana name in Hiragana' do
        valid_child.katakana_name = 'ゆじいたどり'
        valid = valid_child.save
        expect(valid).to be false
      end

      it 'rejects Katakana name in English' do
        valid_child.katakana_name = "B'rett-Tan ner"
        valid = valid_child.save
        expect(valid).to be false
      end

      it 'rejects English name in Japanese' do
        valid_child.en_name = 'サクラ田中'
        valid = valid_child.save
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
    let(:time_slot) { event.time_slots.create(attributes_for(:time_slot)) }
    let(:option) { time_slot.options.create(attributes_for(:option)) }

    it 'knows its registered time slots' do
      slot_reg = time_slot.registrations.create(attributes_for(:registration))
      regsitered_slot = slot_reg.registerable
      expect(regsitered_slot).to eq time_slot
    end

    it 'knows its registered options' do
      opt_reg = option.registrations.create(attributes_for(:registration))
      registered_opt = opt_reg.registerable
      expect(registered_opt).to eq option
    end

    it 'deletes its registrations when deleted' do
      time_slot.registrations.create(attributes_for(:registration, child: child))
      option.registrations.create(attributes_for(:registration, child: child))
      expect { child.destroy }.to \
        change(Registration, :count)
        .by(-2)
    end

    it 'deletes option registrations for that slot when slot registration is deleted' do
      slot_reg = time_slot.registrations.create(attributes_for(:registration, child: child))
      option.registrations.create(attributes_for(:registration, child: child))
      expect { slot_reg.destroy }.to \
        change(Registration, :count)
        .by(-2)
    end

    it "knows if it's registered for a registerable" do
      reg = child.registrations.create(registerable: time_slot)
      registered = child.registered?(time_slot)
      expect(registered).to eq reg
    end

    context 'with time_slots through registrations' do
      it "knows which time slots it's attending" do
        time_slot.registrations.create(child: child)
        attending_list = child.time_slots
        expect(attending_list).to include(time_slot)
      end
    end

    context 'with events through time slots' do
      it "knows which events it's attending" do
        child.registrations.create(registerable: time_slot)
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

  context 'with regular schedule' do
    it 'knows its schedule' do
      schedule = child.create_regular_schedule(attributes_for(:regular_schedule))
      child_schedule = child.regular_schedule
      expect(child_schedule).to eq schedule
    end

    it 'can find all children who attend on a given day' do
      child.create_regular_schedule(monday: true)
      fri_child = create(:child, ssid: 2)
      fri_child.create_regular_schedule(friday: true)
      friday_children = described_class.attend_friday
      expect(friday_children).to contain_exactly(fri_child)
    end
  end
end
