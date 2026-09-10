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

ActiveRecord::Schema[8.1].define(version: 2026_08_21_044510) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "buildings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "site_id", null: false
    t.string "timezone"
    t.datetime "updated_at", null: false
    t.index ["site_id", "name"], name: "index_buildings_on_site_id_and_name", unique: true
    t.index ["site_id"], name: "index_buildings_on_site_id"
  end

  create_table "calendar_sources", force: :cascade do |t|
    t.text "config"
    t.datetime "created_at", null: false
    t.integer "credential_version", default: 0, null: false
    t.datetime "last_reported_at"
    t.integer "provider"
    t.integer "room_id", null: false
    t.datetime "updated_at", null: false
    t.datetime "webhook_expires_at"
    t.string "webhook_subscription_id"
    t.index ["room_id"], name: "index_calendar_sources_on_room_id", unique: true
  end

  create_table "devices", force: :cascade do |t|
    t.string "api_key_digest"
    t.string "apns_token"
    t.datetime "created_at", null: false
    t.string "device_identifier"
    t.datetime "last_seen_at"
    t.string "mdm_device_id"
    t.datetime "paired_at"
    t.string "pairing_code"
    t.datetime "pairing_code_expires_at"
    t.integer "room_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["device_identifier"], name: "index_devices_on_device_identifier", unique: true
    t.index ["mdm_device_id"], name: "index_devices_on_mdm_device_id", unique: true
    t.index ["room_id"], name: "index_devices_on_room_id"
  end

  create_table "floors", force: :cascade do |t|
    t.integer "building_id", null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["building_id", "name"], name: "index_floors_on_building_id_and_name", unique: true
    t.index ["building_id", "position"], name: "index_floors_on_building_id_and_position", unique: true
    t.index ["building_id"], name: "index_floors_on_building_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rooms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "floor_id", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["floor_id", "name"], name: "index_rooms_on_floor_id_and_name", unique: true
    t.index ["floor_id"], name: "index_rooms_on_floor_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "name"], name: "index_sites_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_sites_on_organization_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "buildings", "sites"
  add_foreign_key "calendar_sources", "rooms"
  add_foreign_key "devices", "rooms"
  add_foreign_key "floors", "buildings"
  add_foreign_key "rooms", "floors"
  add_foreign_key "sessions", "users"
  add_foreign_key "sites", "organizations"
end
