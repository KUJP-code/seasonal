# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification do
  context 'when valid' do
    it 'saves' do
      valid_notif = build(:notification)
      valid = valid_notif.save!
      expect(valid).to be true
    end

    it 'is created unread' do
      notif = create(:notification)
      notif_read = notif.read
      expect(notif_read).to be false
    end
  end

  context 'with user' do
    let(:user) { create(:user) }

    it 'knows user' do
      notif = user.notifications.create!(attributes_for(:notification))
      notif_user = notif.user
      expect(notif_user).to eq user
    end

    it 'user knows it' do
      notif = user.notifications.create!(attributes_for(:notification))
      user_notifs = user.notifications
      expect(user_notifs).to contain_exactly(notif)
    end
  end
end
