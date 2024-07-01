# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentUploadPolicy do
  subject(:policy) { described_class.new(user, document_upload) }

  let(:document_upload) { build(:document_upload) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it { is_expected.to authorize_action(:index) }

    it 'scopes to all document uploads' do
      expect(Pundit.policy_scope!(user, DocumentUpload))
        .to eq(DocumentUpload.all)
    end
  end

  context 'when area manager' do
    let(:user) { build(:area_manager) }

    it { is_expected.to authorize_action(:index) }

    it 'scopes to all document uploads for area schools' do
      user.managed_areas << create(:area)
      area_school = create(:school, area: user.managed_areas.first)
      area_uploads = create_list(:document_upload, 2, school: area_school)
      create(:document_upload)
      user.save
      expect(Pundit.policy_scope!(user, DocumentUpload))
        .to match_array(area_uploads)
    end
  end

  context 'when school manager' do
    let(:user) { build(:school_manager) }

    it { is_expected.to authorize_action(:index) }

    it 'scopes to all document uploads for managed schools' do
      school = create(:school)
      user.managed_schools << school
      school_uploads = create_list(:document_upload, 2, school:)
      create(:document_upload)
      user.save
      expect(Pundit.policy_scope!(user, DocumentUpload))
        .to match_array(school_uploads)
    end
  end

  context 'when statistician' do
    let(:user) { build(:statistician) }

    it { is_expected.not_to authorize_action(:index) }

    it 'scopes to nothing' do
      expect(Pundit.policy_scope!(user, DocumentUpload)).to be_empty
    end
  end

  context 'when customer' do
    let(:user) { build(:customer) }

    it { is_expected.not_to authorize_action(:index) }

    it 'scopes to nothing' do
      expect(Pundit.policy_scope!(user, DocumentUpload)).to be_empty
    end
  end
end
