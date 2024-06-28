# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentUpload do
  it 'has a valid factory' do
    expect(build(:document_upload)).to be_valid
  end

  it 'does not allow the document to be an unsupported type' do
    invalid_document = Rails.root.join('spec/models/document_upload_spec.rb').open
    expect(build(:document_upload, document: invalid_document)).not_to be_valid
  end
end
