# frozen_string_literal: true

class MailerSubscriptionUnsubcribesController < ApplicationController
  before_action :set_user, only: %i[show update]
  before_action :set_mailer_subscription, only: %i[show update]

  def show
    @message = if @mailer_subscription.update(subscribed: false)
                 'メールの配信を停止いたしました。'
               else
                 'ユーザーが見つからなかったため、配信を停止できませんでした。'
               end
  end

  def update
    if @mailer_subscription.toggle!(:subscribed)
      redirect_to root_path, notice: 'メールの配信を停止いたしました。'
    else
      redirect_to root_path, notice: 'ユーザーが見つからなかったため、配信を停止できませんでした。'
    end
  end

  private

  def set_user
    @user = GlobalID::Locator.locate_signed params[:id]
    @message = 'ユーザーが見つからなかったため、配信を停止できませんでした。' if @user.nil?
  end

  def set_mailer_subscription
    @mailer_subscription =
      MailerSubscription.find_or_initialize_by(
        user: @user,
        mailer: params[:mailer]
      )
  end
end
