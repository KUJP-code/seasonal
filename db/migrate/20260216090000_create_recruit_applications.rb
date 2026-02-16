# frozen_string_literal: true

class CreateRecruitApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :recruit_applications do |t|
      t.string :role, null: false

      t.string :email, null: false
      t.string :phone, null: false
      t.string :full_name, null: false
      t.date :date_of_birth, null: false
      t.text :full_address, null: false

      t.string :gender
      t.string :highest_education
      t.text :employment_history
      t.text :reason_for_application
      t.string :nationality
      t.string :work_visa_status
      t.text :questions

      t.boolean :privacy_policy_consent, null: false, default: false
      t.string :privacy_policy_url

      t.string :utm_source
      t.string :utm_medium
      t.string :utm_campaign
      t.string :utm_term
      t.string :utm_content
      t.string :gclid
      t.string :fbclid
      t.string :ttclid

      t.string :tracking_link_slug
      t.string :tracking_click_id
      t.string :attribution_method
      t.text :landing_page_url
      t.text :referrer_url
      t.jsonb :raw_tracking, null: false, default: {}

      t.string :ip_address
      t.text :user_agent
      t.string :locale

      t.timestamps
    end

    add_index :recruit_applications, :created_at
    add_index :recruit_applications, :role
    add_index :recruit_applications, :utm_source
    add_index :recruit_applications, :utm_campaign
    add_index :recruit_applications, :tracking_link_slug
  end
end
