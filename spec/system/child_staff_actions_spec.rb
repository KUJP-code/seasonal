# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Child staff actions', :js do
  let(:staff) { create(:area_manager) }
  let(:child) { create(:child, received_hat: false) }

  before do
    sign_in staff
    page.current_window.resize_to(1400, 1200)
  end

  after do
    sign_out staff
  end

  it 'lets staff mark that a child has received a hat' do
    visit child_path(id: child.id)

    expect(page).to have_button('帽子ありにする')

    click_button '帽子ありにする'

    expect(page).to have_button('帽子なしにする')
    expect(page).to have_no_button('帽子ありにする')
    expect(child.reload.received_hat).to be(true)
  end

  it 'lets staff remove the hat flag if it was set by mistake' do
    child.update_column(:received_hat, true)

    visit child_path(id: child.id)

    expect(page).to have_button('帽子なしにする')

    click_button '帽子なしにする'

    expect(page).to have_button('帽子ありにする')
    expect(page).to have_no_button('帽子なしにする')
    expect(child.reload.received_hat).to be(false)
  end
end
