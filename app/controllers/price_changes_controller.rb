# frozen_string_literal: true

# Bookings repriced by monthly weekday uploads, for school managers to check.
class PriceChangesController < ApplicationController
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  SEEN_SHOWN = 50

  def index
    authorize PriceChange
    load_changes
  end

  def update
    change = authorize PriceChange.find(params[:id])
    params[:seen] ? change.mark_seen!(current_user) : change.update!(seen_at: nil, seen_by: nil)
    load_changes

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to price_changes_path, status: :see_other }
    end
  end

  private

  def load_changes
    changes = policy_scope(PriceChange).includes(invoice: %i[event child])
    @unseen = changes.unseen.order(updated_at: :desc).to_a
    @seen = changes.seen.includes(:seen_by).order(seen_at: :desc).limit(SEEN_SHOWN).to_a
  end
end
