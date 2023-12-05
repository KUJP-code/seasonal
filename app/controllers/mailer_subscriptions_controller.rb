# frozen_string_literal: true

# Allows users to manage their email preferences
class MailerSubscriptionsController < ApplicationController
  before_action :set_mailer_subscription, only: :update
  before_action :handle_unauthorized, only: :update

  def index
    @mailer_subscriptions = MailerSubscription::MAILERS.items.map do |item|
      MailerSubscription.find_or_initialize_by(mailer: item[:class], user: current_user)
    end
  end

  def create
    @mailer_subscription = current_user.mailer_subscriptions.build(mailer_subscription_params)
    @mailer_subscription.subscribed = true
    if @mailer_subscription.save
      redirect_to mailer_subscriptions_path,
                  notice: t('success', model: 'メール配信登録', action: '追加')
    else
      redirect_to mailer_subscriptions_path,
                  alter: @mailer_subscription.errors.full_messages.to_sentence.to_s
    end
  end

  def update
    if @mailer_subscription.toggle!(:subscribed)
      redirect_to mailer_subscriptions_path,
                  notice: t('success', model: 'メール配信登録', action: '更新')
    else
      redirect_to mailer_subscriptions_path,
                  alter: @mailer_subscription.errors.full_messages.to_sentence.to_s
    end
  end

  private

  def mailer_subscription_params
    params.require(:mailer_subscription).permit(:mailer)
  end

  def set_mailer_subscription
    @mailer_subscription = MailerSubscription.find(params[:id])
  end

  def handle_unauthorized
    redirect_to root_path,
                status: :unauthorized,
                notice: t('.unauthorized') and return if current_user != @mailer_subscription.user
  end
end
