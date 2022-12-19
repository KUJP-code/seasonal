require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  context "when valid" do
    let(:valid_user) {build(:user)}

    it "saves the User" do
      saves = valid_user.save
      expect(saves).to be true
    end
  end
end
