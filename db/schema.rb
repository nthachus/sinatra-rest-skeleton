# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_12_17_022834) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "uploads", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "key", limit: 50, null: false
    t.string "name", limit: 255, null: false
    t.bigint "size", null: false
    t.string "mime_type", limit: 255
    t.bigint "last_modified"
    t.jsonb "extra", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by"
    t.bigint "updated_by"
    t.index ["key"], name: "index_uploads_on_key", unique: true
    t.index ["user_id"], name: "index_uploads_on_user_id"
  end

  create_table "user_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "key", limit: 50, null: false
    t.jsonb "value", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_user_sessions_on_key", unique: true
    t.index ["user_id"], name: "index_user_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "role", limit: 2, default: 0, null: false
    t.string "username", limit: 255, null: false
    t.string "password_digest", limit: 100
    t.string "name", limit: 255, null: false
    t.string "email", limit: 255
    t.jsonb "profile", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.bigint "created_by"
    t.bigint "updated_by"
    t.bigint "deleted_by"
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "uploads", "users", on_update: :cascade, on_delete: :cascade
  add_foreign_key "user_sessions", "users", on_update: :cascade, on_delete: :cascade
end
