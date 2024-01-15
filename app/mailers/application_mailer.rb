# frozen_string_literal: true

# Base class for all mailers
class ApplicationMailer < ActionMailer::Base
  before_action :set_user
  before_action :set_unsubscribe_url, if: :should_unsubscribe?
  before_action :set_mailer_subscriptions_url, if: :should_unsubscribe?

  after_action :prevent_delivery_if_recipient_opted_out, if: :should_unsubscribe?

  default from: 'bookings@kids-up.app',
          headers: {
            'List-Unsubscribe-Post' => 'List-Unsubscribe=One-Click',
            'List-Unsubscribe' => 'https://kids-up.app/mailer_subscriptions'
          }
  layout 'mailer', except: %i[inquiry setsu_inquiry]

  private

  def prevent_delivery_if_recipient_opted_out
    mail.perform_deliveries = @user.subscribed_to_mailer? self.class.to_s
  end

  def set_user
    @user = params[:user]
  end

  def set_unsubscribe_url
    @unsubscribe_url = mailer_subscription_unsubcribe_url(@user.to_sgid.to_s, mailer: self.class)
  end

  def set_mailer_subscriptions_url
    @mailer_subscriptions_url = mailer_subscriptions_url
  end

  def should_unsubscribe?
    @user.present? && @user.respond_to?(:subscribed_to_mailer?)
  end
end
