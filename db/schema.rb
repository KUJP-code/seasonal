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

ActiveRecord::Schema[7.0].define(version: 2023_01_10_032157) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "areas", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "children", force: :cascade do |t|
    t.string "ja_first_name"
    t.string "ja_family_name"
    t.string "katakana_name"
    t.string "en_name"
    t.integer "category", default: 0
    t.date "birthday"
    t.integer "level", default: 0
    t.string "allergies"
    t.bigint "ssid"
    t.string "ele_school_name"
    t.boolean "post_photos"
    t.boolean "needs_hat"
    t.boolean "received_hat"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_id"
    t.bigint "school_id"
    t.index ["birthday"], name: "index_children_on_birthday"
    t.index ["parent_id"], name: "index_children_on_parent_id"
    t.index ["school_id"], name: "index_children_on_school_id"
    t.index ["ssid"], name: "index_children_on_ssid", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.date "start_date"
    t.date "end_date"
    t.bigint "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_events_on_school_id"
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
    t.string "description"
    t.integer "cost"
    t.bigint "time_slot_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["time_slot_id"], name: "index_options_on_time_slot_id"
  end

  create_table "registrations", force: :cascade do |t|
    t.integer "cost"
    t.bigint "child_id", null: false
    t.string "registerable_type", null: false
    t.bigint "registerable_id", null: false
    t.boolean "paid", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id"], name: "index_registrations_on_child_id"
    t.index ["registerable_type", "registerable_id"], name: "index_registrations_on_registerable"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "phone"
    t.bigint "area_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_schools_on_area_id"
  end

  create_table "time_slots", force: :cascade do |t|
    t.string "name"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "description"
    t.integer "max_attendees"
    t.integer "cost"
    t.datetime "registration_deadline"
    t.bigint "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_time_slots_on_event_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "ja_first_name"
    t.string "ja_family_name"
    t.string "katakana_name"
    t.string "en_name"
    t.string "username"
    t.integer "role", default: 0
    t.string "address"
    t.string "phone"
    t.bigint "school_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["school_id"], name: "index_users_on_school_id"
    t.index ["username"], name: "index_users_on_username", unique: true
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

  add_foreign_key "children", "schools"
  add_foreign_key "children", "users", column: "parent_id"
  add_foreign_key "events", "schools"
  add_foreign_key "managements", "users", column: "manager_id"
  add_foreign_key "options", "time_slots"
  add_foreign_key "registrations", "children"
  add_foreign_key "schools", "areas"
  add_foreign_key "time_slots", "events"
  add_foreign_key "users", "schools"
end
