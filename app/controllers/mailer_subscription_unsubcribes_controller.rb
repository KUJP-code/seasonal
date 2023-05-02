# app/controllers/mailer_subscription_unsubcribes_controller.rb

# Allows for automatic unsubscription from emails
class MailerSubscriptionUnsubcribesController < ApplicationController
  before_action :set_user, only: %i[show update]
  before_action :set_mailer_subscription, only: %i[show update]

  def show
    @message = if @mailer_subscription.update(subscribed: false)
                 "You've successfully unsubscribed from this email."
               else
                 'There was an error'
               end
  end

  def update
    if @mailer_subscription.toggle!(:subscribed)
      redirect_to root_path, notice: t('.subscription_updated')
    else
      redirect_to root_path, notice: t('.subscription_not_updated')
    end
  end

  private

  def set_user
    @user = GlobalID::Locator.locate_signed params[:id]
    @message = 'There was an error' if @user.nil?
  end

  def set_mailer_subscription
    @mailer_subscription =
      MailerSubscription.find_or_initialize_by(
        user: @user,
        mailer: params[:mailer]
      )
  end
end
