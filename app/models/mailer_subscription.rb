# Handles a User's subscription status
class MailerSubscription < ApplicationRecord
  belongs_to :user

  MAILERS =
    OpenStruct.new(
      items: [
        {
          class: 'InvoiceMailer',
          name: 'お申込内容確認メール',
          description: 'お申込内容確認メール'
        }
      ]
    ).freeze

  validates :subscribed, inclusion: [true, false], allow_nil: true
  validates :mailer, presence: true
  validates :mailer, inclusion: MAILERS.items.map { |item| item[:class] }
  validates :user, uniqueness: { scope: :mailer }

  # @mailer_subscription.details
  # => [{:class => "MarketingMailer", :name => "Marketing Emails", :description => "Updates on promotions and sales."}]
  def details
    MailerSubscription::MAILERS.items.select { |item| item[:class] == mailer }
  end

  # @mailer_subscription.name
  # => "Marketing Emails"
  def name
    details[0][:name]
  end

  # @mailer_subscription.name
  # => "Updates on promotions and sales."
  def description
    details[0][:description]
  end

  # @mailer_subscription.name
  # => "Subscribe to"
  def action
    subscribed? ? 'を受信しない' : 'を受信する'
  end

  # @mailer_subscription.name
  # => "Subscribe to Marketing Emails"
  def call_to_action
    "#{name} #{action}"
  end
end
