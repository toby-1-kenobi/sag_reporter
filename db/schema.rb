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

ActiveRecord::Schema.define(version: 20160301045323) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_points", force: :cascade do |t|
    t.text     "content",                       null: false
    t.integer  "responsible_id",                null: false
    t.integer  "status",            default: 0, null: false
    t.integer  "record_creator_id"
    t.integer  "event_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "action_points", ["event_id"], name: "index_action_points_on_event_id", using: :btree
  add_index "action_points", ["record_creator_id"], name: "index_action_points_on_record_creator_id", using: :btree
  add_index "action_points", ["responsible_id"], name: "index_action_points_on_responsible_id", using: :btree

  create_table "attendances", force: :cascade do |t|
    t.integer  "person_id",  null: false
    t.integer  "event_id",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "attendances", ["event_id", "person_id"], name: "index_attendances_on_event_id_and_person_id", unique: true, using: :btree
  add_index "attendances", ["event_id"], name: "index_attendances_on_event_id", using: :btree
  add_index "attendances", ["person_id"], name: "index_attendances_on_person_id", using: :btree

  create_table "challenge_reports", force: :cascade do |t|
    t.integer  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "creations", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "mt_resource_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "creations", ["mt_resource_id"], name: "index_creations_on_mt_resource_id", using: :btree
  add_index "creations", ["person_id", "mt_resource_id"], name: "index_people_mt_resources", unique: true, using: :btree
  add_index "creations", ["person_id"], name: "index_creations_on_person_id", using: :btree

  create_table "districts", force: :cascade do |t|
    t.string   "name",         null: false
    t.integer  "geo_state_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "districts", ["geo_state_id"], name: "index_districts_on_geo_state_id", using: :btree
  add_index "districts", ["name"], name: "index_districts_on_name", using: :btree

  create_table "events", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "event_label",        null: false
    t.date     "event_date",         null: false
    t.integer  "participant_amount"
    t.integer  "purpose"
    t.text     "content"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "village"
    t.integer  "geo_state_id",       null: false
    t.string   "sub_district_name"
    t.string   "district_name"
    t.integer  "sub_district_id"
  end

  add_index "events", ["geo_state_id"], name: "index_events_on_geo_state_id", using: :btree
  add_index "events", ["sub_district_id"], name: "index_events_on_sub_district_id", using: :btree
  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree

  create_table "events_languages", id: false, force: :cascade do |t|
    t.integer "event_id",    null: false
    t.integer "language_id", null: false
  end

  add_index "events_languages", ["event_id", "language_id"], name: "index_events_languages", unique: true, using: :btree

  create_table "events_purposes", id: false, force: :cascade do |t|
    t.integer "event_id"
    t.integer "purpose_id"
  end

  add_index "events_purposes", ["event_id", "purpose_id"], name: "index_events_purposes_on_event_id_and_purpose_id", unique: true, using: :btree
  add_index "events_purposes", ["event_id"], name: "index_events_purposes_on_event_id", using: :btree
  add_index "events_purposes", ["purpose_id"], name: "index_events_purposes_on_purpose_id", using: :btree

  create_table "geo_states", force: :cascade do |t|
    t.string   "name",       null: false
    t.integer  "zone_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "geo_states", ["zone_id"], name: "index_geo_states_on_zone_id", using: :btree

  create_table "geo_states_users", id: false, force: :cascade do |t|
    t.integer "geo_state_id", null: false
    t.integer "user_id",      null: false
  end

  add_index "geo_states_users", ["geo_state_id", "user_id"], name: "index_geo_states_users_on_geo_state_id_and_user_id", unique: true, using: :btree
  add_index "geo_states_users", ["user_id", "geo_state_id"], name: "index_geo_states_users_on_user_id_and_geo_state_id", using: :btree

  create_table "impact_reports", force: :cascade do |t|
    t.integer  "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "impact_reports_languages", id: false, force: :cascade do |t|
    t.integer "impact_report_id", null: false
    t.integer "language_id",      null: false
  end

  add_index "impact_reports_languages", ["impact_report_id", "language_id"], name: "index_impact_reports_languages", unique: true, using: :btree

  create_table "impact_reports_progress_markers", id: false, force: :cascade do |t|
    t.integer "impact_report_id",   null: false
    t.integer "progress_marker_id", null: false
  end

  add_index "impact_reports_progress_markers", ["impact_report_id", "progress_marker_id"], name: "index_impact_reports_progress_markers_on_ir_and_pm", unique: true, using: :btree
  add_index "impact_reports_progress_markers", ["progress_marker_id", "impact_report_id"], name: "index_impact_reports_progress_markers_on_pm_and_ir", using: :btree

  create_table "language_progresses", force: :cascade do |t|
    t.integer  "progress_marker_id", null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "state_language_id"
  end
  
  add_index "language_progresses", ["progress_marker_id"], name: "index_language_progresses_on_progress_marker_id", using: :btree
  add_index "language_progresses", ["state_language_id"], name: "index_language_progresses_on_state_language_id", using: :btree

  create_table "languages", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "lwc"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "colour",      default: "white", null: false
    t.boolean  "interface",   default: false
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

  create_table "mt_resources", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name",                           null: false
    t.text     "description"
    t.integer  "language_id",                    null: false
    t.boolean  "cc_share_alike", default: false, null: false
    t.integer  "category",                       null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "geo_state_id",                   null: false
  end

  add_index "mt_resources", ["category"], name: "index_mt_resources_on_category", using: :btree
  add_index "mt_resources", ["geo_state_id"], name: "index_mt_resources_on_geo_state_id", using: :btree
  add_index "mt_resources", ["language_id"], name: "index_mt_resources_on_language_id", using: :btree
  add_index "mt_resources", ["user_id"], name: "index_mt_resources_on_user_id", using: :btree

  create_table "output_counts", force: :cascade do |t|
    t.integer  "output_tally_id",             null: false
    t.integer  "user_id",                     null: false
    t.integer  "language_id",                 null: false
    t.integer  "amount",          default: 0, null: false
    t.integer  "year",                        null: false
    t.integer  "month",                       null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "geo_state_id",                null: false
  end

  add_index "output_counts", ["geo_state_id"], name: "index_output_counts_on_geo_state_id", using: :btree
  add_index "output_counts", ["language_id"], name: "index_output_counts_on_language_id", using: :btree
  add_index "output_counts", ["output_tally_id"], name: "index_output_counts_on_output_tally_id", using: :btree
  add_index "output_counts", ["user_id"], name: "index_output_counts_on_user_id", using: :btree

  create_table "output_tallies", force: :cascade do |t|
    t.integer  "topic_id",    null: false
    t.string   "name",        null: false
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "output_tallies", ["topic_id"], name: "index_output_tallies_on_topic_id", using: :btree

  create_table "people", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "phone"
    t.text     "address"
    t.boolean  "intern"
    t.boolean  "facilitator"
    t.boolean  "pastor"
    t.integer  "language_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "user_id"
    t.integer  "geo_state_id", null: false
  end

  add_index "people", ["geo_state_id"], name: "index_people_on_geo_state_id", using: :btree
  add_index "people", ["language_id"], name: "index_people_on_language_id", using: :btree
  add_index "people", ["user_id"], name: "index_people_on_user_id", using: :btree

  create_table "permissions", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "category"
  end

  add_index "permissions", ["name"], name: "index_permissions_on_name", unique: true, using: :btree

  create_table "permissions_roles", id: false, force: :cascade do |t|
    t.integer "role_id"
    t.integer "permission_id"
  end

  create_table "planning_reports", force: :cascade do |t|
    t.integer  "status",     default: 1, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "progress_markers", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "topic_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "weight",      default: 1, null: false
  end

  add_index "progress_markers", ["topic_id"], name: "index_progress_markers_on_topic_id", using: :btree

  create_table "progress_updates", force: :cascade do |t|
    t.integer  "user_id",              null: false
    t.integer  "language_progress_id", null: false
    t.integer  "progress",             null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "geo_state_id",         null: false
    t.integer  "month",                null: false
    t.integer  "year",                 null: false
  end

  add_index "progress_updates", ["created_at"], name: "index_progress_updates_on_created_at", using: :btree
  add_index "progress_updates", ["geo_state_id"], name: "index_progress_updates_on_geo_state_id", using: :btree
  add_index "progress_updates", ["language_progress_id"], name: "index_progress_updates_on_language_progress_id", using: :btree
  add_index "progress_updates", ["user_id"], name: "index_progress_updates_on_user_id", using: :btree

  create_table "purposes", force: :cascade do |t|
    t.string   "name",        null: false
    t.string   "description", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "reports", force: :cascade do |t|
    t.integer  "reporter_id",                     null: false
    t.text     "content",                         null: false
    t.integer  "state",               default: 1, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "mt_society"
    t.boolean  "mt_church"
    t.boolean  "needs_society"
    t.boolean  "needs_church"
    t.integer  "event_id"
    t.integer  "geo_state_id",                    null: false
    t.date     "report_date",                     null: false
    t.integer  "planning_report_id"
    t.integer  "impact_report_id"
    t.integer  "challenge_report_id"
  end

  add_index "reports", ["challenge_report_id"], name: "index_reports_on_challenge_report_id", using: :btree
  add_index "reports", ["event_id"], name: "index_reports_on_event_id", using: :btree
  add_index "reports", ["geo_state_id"], name: "index_reports_on_geo_state_id", using: :btree
  add_index "reports", ["impact_report_id"], name: "index_reports_on_impact_report_id", using: :btree
  add_index "reports", ["planning_report_id"], name: "index_reports_on_planning_report_id", using: :btree
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

  create_table "state_languages", force: :cascade do |t|
    t.integer  "geo_state_id"
    t.integer  "language_id"
    t.boolean  "project",      default: false, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "state_languages", ["geo_state_id"], name: "index_state_languages_on_geo_state_id", using: :btree
  add_index "state_languages", ["language_id"], name: "index_state_languages_on_language_id", using: :btree

  create_table "sub_districts", force: :cascade do |t|
    t.string   "name",        null: false
    t.integer  "district_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "sub_districts", ["district_id"], name: "index_sub_districts_on_district_id", using: :btree
  add_index "sub_districts", ["name"], name: "index_sub_districts_on_name", using: :btree

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
    t.integer  "user_id"
  end

  add_index "tally_updates", ["languages_tally_id"], name: "index_tally_updates_on_languages_tally_id", using: :btree
  add_index "tally_updates", ["user_id"], name: "index_tally_updates_on_user_id", using: :btree

  create_table "topics", force: :cascade do |t|
    t.string   "name",                          null: false
    t.text     "description"
    t.string   "colour",      default: "white", null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "translatables", force: :cascade do |t|
    t.string   "identifier", null: false
    t.text     "content",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "translations", force: :cascade do |t|
    t.integer  "translatable_id"
    t.integer  "language_id"
    t.text     "content"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "translations", ["language_id"], name: "index_translations_on_language_id", using: :btree
  add_index "translations", ["translatable_id"], name: "index_translations_on_translatable_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "phone"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.integer  "role_id"
    t.integer  "mother_tongue_id",      null: false
    t.integer  "interface_language_id"
  end

  add_index "users", ["interface_language_id"], name: "index_users_on_interface_language_id", using: :btree
  add_index "users", ["mother_tongue_id"], name: "index_users_on_mother_tongue_id", using: :btree
  add_index "users", ["phone"], name: "index_users_on_phone", unique: true, using: :btree
  add_index "users", ["role_id"], name: "index_users_on_role_id", using: :btree

  create_table "zones", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "action_points", "events"
  add_foreign_key "action_points", "people", column: "responsible_id"
  add_foreign_key "action_points", "users", column: "record_creator_id"
  add_foreign_key "attendances", "events"
  add_foreign_key "attendances", "people"
  add_foreign_key "creations", "mt_resources"
  add_foreign_key "creations", "people"
  add_foreign_key "districts", "geo_states"
  add_foreign_key "events", "geo_states"
  add_foreign_key "events", "users"
  add_foreign_key "events_purposes", "events"
  add_foreign_key "events_purposes", "purposes"
  add_foreign_key "geo_states", "zones"
  add_foreign_key "language_progresses", "progress_markers"
  add_foreign_key "language_progresses", "state_languages"
  add_foreign_key "languages_tallies", "languages"
  add_foreign_key "languages_tallies", "tallies"
  add_foreign_key "mt_resources", "geo_states"
  add_foreign_key "mt_resources", "languages"
  add_foreign_key "mt_resources", "users"
  add_foreign_key "output_counts", "geo_states"
  add_foreign_key "output_counts", "languages"
  add_foreign_key "output_counts", "output_tallies"
  add_foreign_key "output_counts", "users"
  add_foreign_key "output_tallies", "topics"
  add_foreign_key "people", "geo_states"
  add_foreign_key "people", "languages"
  add_foreign_key "people", "users"
  add_foreign_key "progress_markers", "topics"
  add_foreign_key "progress_updates", "geo_states"
  add_foreign_key "progress_updates", "language_progresses"
  add_foreign_key "progress_updates", "users"
  add_foreign_key "reports", "challenge_reports"
  add_foreign_key "reports", "events"
  add_foreign_key "reports", "geo_states"
  add_foreign_key "state_languages", "geo_states"
  add_foreign_key "state_languages", "languages"
  add_foreign_key "reports", "impact_reports"
  add_foreign_key "reports", "planning_reports"
  add_foreign_key "sub_districts", "districts"
  add_foreign_key "tallies", "topics"
  add_foreign_key "tally_updates", "languages_tallies"
  add_foreign_key "tally_updates", "users"
  add_foreign_key "translations", "languages"
  add_foreign_key "translations", "translatables"
  add_foreign_key "users", "languages", column: "interface_language_id"
end
