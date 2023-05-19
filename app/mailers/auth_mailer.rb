# frozen_string_literal: true

# Lets me customise the Devise layout
class AuthMailer < Devise::Mailer
  layout 'devise_mailer'
end
