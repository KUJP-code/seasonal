# frozen_string_literal: true

class CreateRashimbaInquiries < ActiveRecord::Migration[7.1]
  def change
    create_table :rashimba_inquiries do |t|
      t.string :kind, null: false
      t.string :email, null: false
      t.string :company
      t.string :name
      t.string :phone
      t.text :message
      t.string :child_age
      t.boolean :privacy_consent, null: false
      t.datetime :consented_at, null: false
      t.string :status, null: false, default: 'pending'
      t.text :admin_notes
      t.string :ip_address, null: false
      t.string :submission_key, null: false
      t.string :submission_digest, null: false
      t.datetime :confirmation_sent_at
      t.datetime :notification_sent_at
      t.timestamps
    end

    add_index :rashimba_inquiries, :submission_key, unique: true
    add_index :rashimba_inquiries, %i[ip_address created_at]
    add_index :rashimba_inquiries, %i[email created_at]
    add_index :rashimba_inquiries, %i[kind status created_at]
    add_check_constraint :rashimba_inquiries,
                         "kind IN ('sponsor', 'release_notification')", name: 'rashimba_kind'
    add_check_constraint :rashimba_inquiries,
                         "status IN ('pending', 'reviewed', 'resolved')", name: 'rashimba_status'
    add_check_constraint :rashimba_inquiries, 'privacy_consent = TRUE', name: 'rashimba_consent'
  end
end
