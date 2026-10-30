# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Invoice history display' do
  let(:admin) { create(:admin) }
  let(:child) { create(:internal_child, parent: create(:customer)) }
  let(:slot) { create(:time_slot) }
  let(:invoice) do
    create(:invoice, event: slot.event, child:,
                     slot_regs_attributes: [{ child_id: child.id, registerable: slot }])
  end

  before { sign_in admin }

  def add_history(actor)
    invoice.versions.create!(event: 'update', whodunnit: actor,
                             object: PaperTrail.serializer.dump(invoice.attributes))
  end

  [nil, 'codex: requested event bundle recalculation'].each do |actor|
    it "renders system-generated history with actor #{actor.inspect}" do
      add_history(actor)

      get invoice_path(id: invoice.id, locale: :en)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Changed by: System')
    end
  end

  it 'renders history when its original user no longer exists' do
    invoice
    add_history((User.maximum(:id) + 1).to_s)

    get invoice_path(id: invoice.id, locale: :en)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Changed by: Deleted user')
  end

  it 'retains the name of an existing user in the history' do
    add_history(admin.id.to_s)

    get invoice_path(id: invoice.id, locale: :en)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Changed by: #{admin.name}")
  end

  it 'allows parents to open their invoice with system-generated history' do
    add_history('codex: requested event bundle recalculation')
    sign_in child.parent

    get invoice_path(id: invoice.id, locale: :en)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Changed by: System')
  end
end
