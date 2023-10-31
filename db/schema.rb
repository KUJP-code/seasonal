# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_10_31_090854) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "adjustments", force: :cascade do |t|
    t.integer "change"
    t.string "reason"
    t.bigint "invoice_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_adjustments_on_invoice_id"
  end

  create_table "areas", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "children", force: :cascade do |t|
    t.string "name"
    t.string "katakana_name"
    t.string "en_name"
    t.integer "category", default: 0
    t.integer "grade", default: 3
    t.date "birthday"
    t.boolean "kindy", default: false
    t.string "allergies"
    t.bigint "ssid"
    t.string "ele_school_name"
    t.integer "photos", default: 0
    t.boolean "received_hat", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_id"
    t.bigint "school_id"
    t.boolean "first_seasonal", default: true
    t.index ["birthday"], name: "index_children_on_birthday"
    t.index ["parent_id"], name: "index_children_on_parent_id"
    t.index ["school_id"], name: "index_children_on_school_id"
    t.index ["ssid"], name: "index_children_on_ssid", unique: true
  end

  create_table "coupons", force: :cascade do |t|
    t.string "code"
    t.string "couponable_type", null: false
    t.bigint "couponable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["couponable_type", "couponable_id"], name: "index_coupons_on_couponable"
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.integer "goal"
    t.date "start_date"
    t.date "end_date"
    t.bigint "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "member_prices_id"
    t.bigint "non_member_prices_id"
    t.index ["member_prices_id"], name: "index_events_on_member_prices_id"
    t.index ["non_member_prices_id"], name: "index_events_on_non_member_prices_id"
    t.index ["school_id"], name: "index_events_on_school_id"
  end

  create_table "inquiries", force: :cascade do |t|
    t.bigint "setsumeikai_id", null: false
    t.string "parent_name"
    t.string "phone"
    t.string "email"
    t.string "child_name"
    t.date "child_birthday"
    t.string "kindy"
    t.string "ele_school"
    t.string "planned_school"
    t.date "start_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "referrer"
    t.string "notes"
    t.string "requests"
    t.index ["setsumeikai_id"], name: "index_inquiries_on_setsumeikai_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "total_cost", default: 0
    t.string "summary"
    t.boolean "in_ss", default: false
    t.datetime "seen_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "child_id", null: false
    t.bigint "event_id", null: false
    t.boolean "entered", default: false
    t.boolean "email_sent", default: false
    t.integer "slot_regs_count", default: 0
    t.index ["child_id"], name: "index_invoices_on_child_id"
    t.index ["event_id"], name: "index_invoices_on_event_id"
  end

  create_table "mailer_subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.boolean "subscribed"
    t.string "mailer", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "mailer"], name: "index_mailer_subscriptions_on_user_id_and_mailer", unique: true
    t.index ["user_id"], name: "index_mailer_subscriptions_on_user_id"
  end

  create_table "managements", force: :cascade do |t|
    t.string "manageable_type", null: false
    t.bigint "manageable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "manager_id", null: false
    t.index ["manageable_type", "manageable_id"], name: "index_managements_on_manageable"
    t.index ["manager_id"], name: "index_managements_on_manager_id"
  end

  create_table "options", force: :cascade do |t|
    t.string "name"
    t.integer "cost"
    t.integer "category", default: 0
    t.integer "modifier"
    t.string "optionable_type", null: false
    t.bigint "optionable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "registrations_count", default: 0
    t.index ["optionable_type", "optionable_id"], name: "index_options_on_optionable"
  end

  create_table "price_lists", force: :cascade do |t|
    t.string "name"
    t.jsonb "courses"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "registrations", force: :cascade do |t|
    t.bigint "child_id", null: false
    t.string "registerable_type", null: false
    t.bigint "registerable_id", null: false
    t.bigint "invoice_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id"], name: "index_registrations_on_child_id"
    t.index ["invoice_id"], name: "index_registrations_on_invoice_id"
    t.index ["registerable_id", "child_id", "registerable_type"], name: "idx_reg_per_child", unique: true
    t.index ["registerable_type", "registerable_id"], name: "index_registrations_on_registerable"
  end

  create_table "regular_schedules", force: :cascade do |t|
    t.boolean "monday", default: false
    t.boolean "tuesday", default: false
    t.boolean "wednesday", default: false
    t.boolean "thursday", default: false
    t.boolean "friday", default: false
    t.bigint "child_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id"], name: "index_regular_schedules_on_child_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "phone"
    t.bigint "area_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "details"
    t.string "email"
    t.index ["area_id"], name: "index_schools_on_area_id"
  end

  create_table "setsumeikais", force: :cascade do |t|
    t.datetime "start"
    t.integer "attendance_limit"
    t.bigint "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "inquiries_count"
    t.index ["school_id"], name: "index_setsumeikais_on_school_id"
  end

  create_table "time_slots", force: :cascade do |t|
    t.string "name"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "category", default: 0
    t.boolean "closed", default: false
    t.boolean "morning", default: false
    t.bigint "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "morning_slot_id"
    t.integer "int_modifier", default: 0
    t.integer "ext_modifier", default: 0
    t.boolean "snack"
    t.integer "registrations_count", default: 0
    t.index ["event_id"], name: "index_time_slots_on_event_id"
    t.index ["morning"], name: "index_time_slots_on_morning"
    t.index ["morning_slot_id"], name: "index_time_slots_on_morning_slot_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "name"
    t.string "katakana_name"
    t.integer "role", default: 0
    t.string "postcode"
    t.string "prefecture"
    t.string "address"
    t.string "phone"
    t.string "pin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "adjustments", "invoices"
  add_foreign_key "children", "schools"
  add_foreign_key "children", "users", column: "parent_id"
  add_foreign_key "events", "price_lists", column: "member_prices_id"
  add_foreign_key "events", "price_lists", column: "non_member_prices_id"
  add_foreign_key "events", "schools"
  add_foreign_key "inquiries", "setsumeikais"
  add_foreign_key "invoices", "children"
  add_foreign_key "invoices", "events"
  add_foreign_key "mailer_subscriptions", "users"
  add_foreign_key "managements", "users", column: "manager_id"
  add_foreign_key "registrations", "children"
  add_foreign_key "registrations", "invoices"
  add_foreign_key "regular_schedules", "children"
  add_foreign_key "schools", "areas"
  add_foreign_key "setsumeikais", "schools"
  add_foreign_key "time_slots", "events"
  add_foreign_key "time_slots", "time_slots", column: "morning_slot_id"
end
