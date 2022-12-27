require 'rails_helper'

RSpec.describe Event do
  let(:event) { create(:event) }

  context 'when valid' do
    let(:valid_event) { build(:event) }

    it 'saves' do
      valid = valid_event.save!
      expect(valid).to be true
    end

    # Can't test past events cos of db constraints
    it 'lists current events' do
      current_event = create(:event, start_date: Time.zone.today, end_date: Time.zone.today)
      current_events = described_class.all.current_events
      expect(current_events).to match_array(current_event)
    end

    it 'lists future events' do
      future_event = create(:event, start_date: 2.days.from_now)
      future_events = described_class.all.future_events
      expect(future_events).to match_array(future_event)
    end
  end

  context 'when invalid' do
    it "doesn't save without a name" do
      no_name = build(:event, name: nil)
      valid = no_name.save
      expect(valid).to be false
    end

    it "doesn't save without a description" do
      no_description = build(:event, description: nil)
      valid = no_description.save
      expect(valid).to be false
    end

    it "doesn't save without a start date" do
      no_start_date = build(:event, start_date: nil)
      valid = no_start_date.save
      expect(valid).to be false
    end

    it "doesn't save when start date before current date" do
      past_start = build(:event, start_date: 7.days.ago)
      valid = past_start.save
      expect(valid).to be false
    end

    it "doesn't save without end date" do
      no_end_date = build(:event, end_date: nil)
      valid = no_end_date.save
      expect(valid).to be false
    end

    it "doesn't save when end date before current date" do
      past_end = build(:event, end_date: 7.days.ago)
      valid = past_end.save
      expect(valid).to be false
    end

    it "doesn't save when start date before end date" do
      past_start = build(:event, start_date: 3.days.from_now, end_date: 2.days.from_now)
      valid = past_start.save
      expect(valid).to be false
    end

    it "doesn't save without school" do
      no_school = build(:event, school: nil)
      valid = no_school.save
      expect(valid).to be false
    end
  end
end
