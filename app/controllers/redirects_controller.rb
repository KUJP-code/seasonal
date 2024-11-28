# frozen_string_literal: true

class RedirectsController < ApplicationController
  def choco25
    # Add logic to track the QR code usage
    # For example, log or increment a counter in your database
    Rails.logger.info "Choco25 QR code used at #{Time.current}"

    redirect_to root_path
  end
end
