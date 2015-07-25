# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150724160502) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "languages", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "lwc"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "colour",      default: "white", null: false
  end

  create_table "languages_reports", id: false, force: :cascade do |t|
    t.integer "report_id"
    t.integer "language_id"
  end

  add_index "languages_reports", ["report_id", "language_id"], name: "index_languages_reports_on_report_id_and_language_id", unique: true, using: :btree

  create_table "languages_tallies", force: :cascade do |t|
    t.integer  "language_id"
    t.integer  "tally_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "languages_tallies", ["language_id"], name: "index_languages_tallies_on_language_id", using: :btree
  add_index "languages_tallies", ["tally_id"], name: "index_languages_tallies_on_tally_id", using: :btree

  create_table "languages_users", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "language_id"
  end

  add_index "languages_users", ["user_id", "language_id"], name: "index_languages_users_on_user_id_and_language_id", unique: true, using: :btree

  create_table "permissions", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "permissions", ["name"], name: "index_permissions_on_name", unique: true, using: :btree

  create_table "permissions_roles", id: false, force: :cascade do |t|
    t.integer "role_id"
    t.integer "permission_id"
  end

  create_table "reports", force: :cascade do |t|
    t.integer  "reporter_id",             null: false
    t.text     "content"
    t.integer  "report_type", default: 0, null: false
    t.integer  "state",       default: 1, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "reports", ["report_type"], name: "index_reports_on_report_type", using: :btree
  add_index "reports", ["reporter_id"], name: "index_reports_on_reporter_id", using: :btree
  add_index "reports", ["state"], name: "index_reports_on_state", using: :btree

  create_table "reports_topics", id: false, force: :cascade do |t|
    t.integer "report_id"
    t.integer "topic_id"
  end

  add_index "reports_topics", ["report_id", "topic_id"], name: "index_reports_topics_on_report_id_and_topic_id", unique: true, using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tallies", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "state",       default: 1, null: false
    t.integer  "topic_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "tallies", ["state"], name: "index_tallies_on_state", using: :btree
  add_index "tallies", ["topic_id"], name: "index_tallies_on_topic_id", using: :btree

  create_table "tally_updates", force: :cascade do |t|
    t.integer  "languages_tally_id"
    t.integer  "amount",             default: 0, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "tally_updates", ["languages_tally_id"], name: "index_tally_updates_on_languages_tally_id", using: :btree

  create_table "topics", force: :cascade do |t|
    t.string   "name",                          null: false
    t.text     "description"
    t.string   "colour",      default: "white", null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "phone"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.integer  "role_id"
    t.integer  "mother_tongue_id", null: false
  end

  add_index "users", ["mother_tongue_id"], name: "index_users_on_mother_tongue_id", using: :btree
  add_index "users", ["phone"], name: "index_users_on_phone", unique: true, using: :btree
  add_index "users", ["role_id"], name: "index_users_on_role_id", using: :btree

end
