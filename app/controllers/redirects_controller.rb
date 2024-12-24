# frozen_string_literal: true

class RedirectsController < ApplicationController
  # TODO: Separate increment / logging logic into a private method when we have a new QR code.
  def choco25
    qr_code = QrCode.find_or_create_by(name: 'choco25')

    qr_code.qr_code_usages.create!(
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )

    qr_code.increment(:usage_count)
    Rails.logger.info "Choco25 QR code used at #{Time.current}"

    redirect_to root_path
  end
end
