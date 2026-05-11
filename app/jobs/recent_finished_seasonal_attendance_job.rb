# frozen_string_literal: true

class RecentFinishedSeasonalAttendanceJob < ApplicationJob
  queue_as :default

  LOOKBACK = 1.month

  def perform
    recent_seasonal_names = Event
                            .where(early_bird_discount: 0)
                            .where(end_date: LOOKBACK.ago.to_date..Time.zone.today)
                            .distinct
                            .pluck(:name)

    return if recent_seasonal_names.empty?

    children = Child.joins(:invoices)
                    .where(
                      invoices: { event_id: Event.where(name: recent_seasonal_names).select(:id) },
                      children: { first_seasonal: true }
                    )
                    .distinct

    children.find_each { |child| StudentSeasonalUpdateJob.perform_later(child) }
  end
end
