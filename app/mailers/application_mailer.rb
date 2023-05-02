# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'bookings@kids-up.app'
  layout 'mailer'
end
