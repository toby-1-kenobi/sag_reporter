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

ActiveRecord::Schema.define(version: 20180327103712) do

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

  create_table "cache_backups", force: :cascade do |t|
    t.string   "name",       null: false
    t.text     "value"
    t.datetime "expires"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "cache_backups", ["expires"], name: "index_cache_backups_on_expires", using: :btree
  add_index "cache_backups", ["name"], name: "index_cache_backups_on_name", using: :btree

  create_table "challenge_reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clusters", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "clusters", ["name"], name: "index_clusters_on_name", unique: true, using: :btree

  create_table "creations", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "mt_resource_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "creations", ["mt_resource_id"], name: "index_creations_on_mt_resource_id", using: :btree
  add_index "creations", ["person_id", "mt_resource_id"], name: "index_people_mt_resources", unique: true, using: :btree
  add_index "creations", ["person_id"], name: "index_creations_on_person_id", using: :btree

  create_table "curatings", force: :cascade do |t|
    t.integer  "user_id",      null: false
    t.integer  "geo_state_id", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "curatings", ["geo_state_id"], name: "index_curatings_on_geo_state_id", using: :btree
  add_index "curatings", ["user_id"], name: "index_curatings_on_user_id", using: :btree

  create_table "data_sources", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "data_sources", ["name"], name: "index_data_sources_on_name", unique: true, using: :btree

  create_table "dialects", force: :cascade do |t|
    t.integer  "language_id", null: false
    t.string   "name",        null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "dialects", ["language_id", "name"], name: "language_dialect_names", unique: true, using: :btree
  add_index "dialects", ["language_id"], name: "index_dialects_on_language_id", using: :btree
  add_index "dialects", ["name"], name: "index_dialects_on_name", using: :btree

  create_table "districts", force: :cascade do |t|
    t.string   "name",         null: false
    t.integer  "geo_state_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "districts", ["geo_state_id"], name: "index_districts_on_geo_state_id", using: :btree
  add_index "districts", ["name"], name: "index_districts_on_name", using: :btree

  create_table "edits", force: :cascade do |t|
    t.string   "model_klass_name",                     null: false
    t.integer  "record_id",                            null: false
    t.string   "attribute_name",                       null: false
    t.string   "old_value",                            null: false
    t.string   "new_value",                            null: false
    t.integer  "user_id",                              null: false
    t.integer  "status",               default: 0,     null: false
    t.datetime "curation_date"
    t.datetime "second_curation_date"
    t.text     "record_errors"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "curated_by_id"
    t.boolean  "relationship",         default: false, null: false
    t.text     "creator_comment"
    t.text     "curator_comment"
  end

  add_index "edits", ["created_at"], name: "index_edits_on_created_at", using: :btree
  add_index "edits", ["curated_by_id"], name: "index_edits_on_curated_by_id", using: :btree
  add_index "edits", ["curation_date"], name: "index_edits_on_curation_date", using: :btree
  add_index "edits", ["second_curation_date"], name: "index_edits_on_second_curation_date", using: :btree
  add_index "edits", ["status"], name: "index_edits_on_status", using: :btree
  add_index "edits", ["user_id"], name: "index_edits_on_user_id", using: :btree

  create_table "edits_geo_states", id: false, force: :cascade do |t|
    t.integer "edit_id",      null: false
    t.integer "geo_state_id", null: false
  end

  add_index "edits_geo_states", ["edit_id", "geo_state_id"], name: "index_edits_geo_states_on_edit_id_and_geo_state_id", unique: true, using: :btree

  create_table "events", force: :cascade do |t|
    t.integer  "user_id",            null: false
    t.string   "event_label",        null: false
    t.date     "event_date",         null: false
    t.integer  "participant_amount"
    t.integer  "purpose"
    t.text     "content"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "district_name"
    t.string   "sub_district_name"
    t.string   "village"
    t.integer  "geo_state_id",       null: false
    t.integer  "sub_district_id"
  end

  add_index "events", ["event_date"], name: "index_events_on_event_date", using: :btree
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

  create_table "external_devices", force: :cascade do |t|
    t.string   "device_id"
    t.string   "name"
    t.boolean  "registered", default: false, null: false
    t.integer  "user_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "external_devices", ["user_id"], name: "index_external_devices_on_user_id", using: :btree

  create_table "finish_line_markers", force: :cascade do |t|
    t.string   "name",        null: false
    t.text     "description", null: false
    t.integer  "number",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "finish_line_markers", ["number"], name: "index_finish_line_markers_on_number", using: :btree

  create_table "finish_line_progresses", force: :cascade do |t|
    t.integer  "language_id",                       null: false
    t.integer  "finish_line_marker_id",             null: false
    t.integer  "status",                default: 1, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "finish_line_progresses", ["finish_line_marker_id"], name: "index_finish_line_progresses_on_finish_line_marker_id", using: :btree
  add_index "finish_line_progresses", ["language_id", "finish_line_marker_id"], name: "index_lang_finish_line", unique: true, using: :btree
  add_index "finish_line_progresses", ["language_id"], name: "index_finish_line_progresses_on_language_id", using: :btree

  create_table "geo_states", force: :cascade do |t|
    t.string   "name",       null: false
    t.integer  "zone_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "geo_states", ["name"], name: "index_geo_states_on_name", using: :btree
  add_index "geo_states", ["zone_id"], name: "index_geo_states_on_zone_id", using: :btree

  create_table "geo_states_users", id: false, force: :cascade do |t|
    t.integer "geo_state_id", null: false
    t.integer "user_id",      null: false
  end

  add_index "geo_states_users", ["geo_state_id", "user_id"], name: "index_geo_states_users_on_geo_state_id_and_user_id", unique: true, using: :btree
  add_index "geo_states_users", ["user_id", "geo_state_id"], name: "index_geo_states_users_on_user_id_and_geo_state_id", using: :btree

  create_table "impact_reports", force: :cascade do |t|
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "shareable",          default: false, null: false
    t.boolean  "translation_impact", default: false, null: false
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

  create_table "language_families", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "language_families", ["name"], name: "index_language_families_on_name", unique: true, using: :btree

  create_table "language_names", force: :cascade do |t|
    t.integer  "language_id",                       null: false
    t.string   "name",                              null: false
    t.boolean  "preferred",         default: false, null: false
    t.boolean  "used_by_speakers",  default: false, null: false
    t.boolean  "used_by_outsiders", default: false, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "language_names", ["language_id", "name"], name: "uniq_language_names", unique: true, using: :btree
  add_index "language_names", ["language_id"], name: "index_language_names_on_language_id", using: :btree
  add_index "language_names", ["name"], name: "index_language_names_on_name", using: :btree

  create_table "language_progresses", force: :cascade do |t|
    t.integer  "progress_marker_id", null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "state_language_id"
  end

  add_index "language_progresses", ["progress_marker_id"], name: "index_language_progresses_on_progress_marker_id", using: :btree
  add_index "language_progresses", ["state_language_id"], name: "index_language_progresses_on_state_language_id", using: :btree

  create_table "languages", force: :cascade do |t|
    t.string   "name",                                                  null: false
    t.text     "description"
    t.boolean  "lwc"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.string   "colour",                              default: "white", null: false
    t.string   "iso",                       limit: 3
    t.integer  "family_id"
    t.integer  "population",                limit: 8
    t.integer  "pop_source_id"
    t.text     "location"
    t.integer  "number_of_translations"
    t.integer  "cluster_id"
    t.text     "info"
    t.text     "translation_info"
    t.integer  "translation_need",                    default: 0,       null: false
    t.integer  "translation_progress",                default: 0,       null: false
    t.string   "locale_tag"
    t.integer  "population_all_countries"
    t.string   "population_concentration"
    t.string   "age_distribution"
    t.string   "village_size"
    t.text     "mixed_marriages"
    t.string   "clans"
    t.string   "castes"
    t.string   "genetic_classification"
    t.text     "location_access"
    t.text     "travel"
    t.text     "ethnic_groups_in_area"
    t.string   "religion"
    t.integer  "believers"
    t.boolean  "local_fellowship"
    t.string   "literate_believers"
    t.string   "related_languages"
    t.string   "subgroups"
    t.string   "lexical_similarity"
    t.text     "attitude"
    t.integer  "bible_first_published"
    t.integer  "bible_last_published"
    t.integer  "nt_first_published"
    t.integer  "nt_last_published"
    t.integer  "portions_first_published"
    t.integer  "portions_last_published"
    t.string   "selections_published"
    t.boolean  "nt_out_of_print"
    t.boolean  "tr_committee_established"
    t.string   "translation_consultants"
    t.text     "translation_interest"
    t.text     "translator_background"
    t.text     "translation_local_support"
    t.string   "mt_literacy"
    t.string   "l2_literacy"
    t.string   "script"
    t.text     "attitude_to_lang_dev"
    t.text     "mt_literacy_programs"
    t.boolean  "poetry_print"
    t.boolean  "oral_traditions_print"
    t.integer  "champion_id"
    t.datetime "champion_prompted"
    t.integer  "project_id"
  end

  add_index "languages", ["champion_id"], name: "index_languages_on_champion_id", using: :btree
  add_index "languages", ["cluster_id"], name: "index_languages_on_cluster_id", using: :btree
  add_index "languages", ["family_id"], name: "index_languages_on_family_id", using: :btree
  add_index "languages", ["iso"], name: "index_languages_on_iso", unique: true, using: :btree
  add_index "languages", ["name"], name: "index_languages_on_name", using: :btree
  add_index "languages", ["pop_source_id"], name: "index_languages_on_pop_source_id", using: :btree
  add_index "languages", ["translation_need"], name: "index_languages_on_translation_need", using: :btree
  add_index "languages", ["translation_progress"], name: "index_languages_on_translation_progress", using: :btree

  create_table "languages_reports", id: false, force: :cascade do |t|
    t.integer "report_id"
    t.integer "language_id"
  end

  add_index "languages_reports", ["report_id", "language_id"], name: "index_languages_reports_on_report_id_and_language_id", unique: true, using: :btree

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
    t.integer  "status",         default: 0,     null: false
    t.integer  "publish_year"
    t.string   "url"
    t.text     "how_to_access"
    t.integer  "geo_state_id"
  end

  add_index "mt_resources", ["category"], name: "index_mt_resources_on_category", using: :btree
  add_index "mt_resources", ["created_at"], name: "index_mt_resources_on_created_at", using: :btree
  add_index "mt_resources", ["geo_state_id"], name: "index_mt_resources_on_geo_state_id", using: :btree
  add_index "mt_resources", ["language_id"], name: "index_mt_resources_on_language_id", using: :btree
  add_index "mt_resources", ["publish_year"], name: "index_mt_resources_on_publish_year", using: :btree
  add_index "mt_resources", ["user_id"], name: "index_mt_resources_on_user_id", using: :btree

  create_table "observations", force: :cascade do |t|
    t.integer  "report_id",  null: false
    t.integer  "person_id",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "observations", ["person_id"], name: "index_observations_on_person_id", using: :btree
  add_index "observations", ["report_id", "person_id"], name: "index_reports_people", unique: true, using: :btree
  add_index "observations", ["report_id"], name: "index_observations_on_report_id", using: :btree

  create_table "organisation_engagements", force: :cascade do |t|
    t.integer  "language_id",     null: false
    t.integer  "organisation_id", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "organisation_engagements", ["language_id", "organisation_id"], name: "index_orgs_languages", unique: true, using: :btree
  add_index "organisation_engagements", ["language_id"], name: "index_organisation_engagements_on_language_id", using: :btree
  add_index "organisation_engagements", ["organisation_id"], name: "index_organisation_engagements_on_organisation_id", using: :btree

  create_table "organisation_translations", force: :cascade do |t|
    t.integer  "language_id",     null: false
    t.integer  "organisation_id", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.text     "note"
  end

  add_index "organisation_translations", ["language_id", "organisation_id"], name: "index_orgs_languages_trans", unique: true, using: :btree
  add_index "organisation_translations", ["language_id"], name: "index_organisation_translations_on_language_id", using: :btree
  add_index "organisation_translations", ["organisation_id"], name: "index_organisation_translations_on_organisation_id", using: :btree

  create_table "organisations", force: :cascade do |t|
    t.string   "name",         null: false
    t.string   "abbreviation"
    t.integer  "parent_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "organisations", ["abbreviation"], name: "index_organisations_on_abbreviation", unique: true, using: :btree
  add_index "organisations", ["name"], name: "index_organisations_on_name", unique: true, using: :btree

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
  add_index "people", ["name"], name: "index_people_on_name", using: :btree
  add_index "people", ["user_id"], name: "index_people_on_user_id", using: :btree

  create_table "planning_reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "populations", force: :cascade do |t|
    t.integer  "language_id",                   null: false
    t.integer  "amount",                        null: false
    t.string   "source"
    t.integer  "year"
    t.boolean  "international", default: false, null: false
    t.text     "note"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "populations", ["language_id"], name: "index_populations_on_language_id", using: :btree
  add_index "populations", ["year"], name: "index_populations_on_year", using: :btree

  create_table "progress_markers", force: :cascade do |t|
    t.string   "name"
    t.integer  "topic_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "weight",                default: 1, null: false
    t.integer  "status",                default: 0, null: false
    t.text     "alternate_description"
    t.integer  "number"
  end

  add_index "progress_markers", ["number"], name: "index_progress_markers_on_number", using: :btree
  add_index "progress_markers", ["status"], name: "index_progress_markers_on_status", using: :btree
  add_index "progress_markers", ["topic_id"], name: "index_progress_markers_on_topic_id", using: :btree
  add_index "progress_markers", ["weight"], name: "index_progress_markers_on_weight", using: :btree

  create_table "progress_updates", force: :cascade do |t|
    t.integer  "user_id",              null: false
    t.integer  "language_progress_id", null: false
    t.integer  "progress",             null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "month",                null: false
    t.integer  "year",                 null: false
  end

  add_index "progress_updates", ["created_at"], name: "index_progress_updates_on_created_at", using: :btree
  add_index "progress_updates", ["language_progress_id"], name: "index_progress_updates_on_language_progress_id", using: :btree
  add_index "progress_updates", ["month"], name: "index_progress_updates_on_month", using: :btree
  add_index "progress_updates", ["user_id"], name: "index_progress_updates_on_user_id", using: :btree
  add_index "progress_updates", ["year"], name: "index_progress_updates_on_year", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "projects", ["name"], name: "index_projects_on_name", using: :btree

  create_table "purposes", force: :cascade do |t|
    t.string   "name",        null: false
    t.string   "description", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "reports", force: :cascade do |t|
    t.integer  "reporter_id",                             null: false
    t.text     "content",                                 null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "mt_society"
    t.boolean  "mt_church"
    t.boolean  "needs_society"
    t.boolean  "needs_church"
    t.integer  "event_id"
    t.integer  "geo_state_id",                            null: false
    t.date     "report_date",                             null: false
    t.integer  "planning_report_id"
    t.integer  "impact_report_id"
    t.integer  "challenge_report_id"
    t.integer  "status",              default: 0,         null: false
    t.integer  "sub_district_id"
    t.string   "location"
    t.string   "client",              default: "LCR",     null: false
    t.string   "version",             default: "unknown", null: false
    t.boolean  "significant",         default: false,     null: false
  end

  add_index "reports", ["challenge_report_id"], name: "index_reports_on_challenge_report_id", using: :btree
  add_index "reports", ["event_id"], name: "index_reports_on_event_id", using: :btree
  add_index "reports", ["geo_state_id"], name: "index_reports_on_geo_state_id", using: :btree
  add_index "reports", ["impact_report_id"], name: "index_reports_on_impact_report_id", using: :btree
  add_index "reports", ["planning_report_id"], name: "index_reports_on_planning_report_id", using: :btree
  add_index "reports", ["report_date"], name: "index_reports_on_report_date", using: :btree
  add_index "reports", ["reporter_id"], name: "index_reports_on_reporter_id", using: :btree
  add_index "reports", ["status"], name: "index_reports_on_status", using: :btree
  add_index "reports", ["sub_district_id"], name: "index_reports_on_sub_district_id", using: :btree

  create_table "reports_topics", id: false, force: :cascade do |t|
    t.integer "report_id"
    t.integer "topic_id"
  end

  add_index "reports_topics", ["report_id", "topic_id"], name: "index_reports_topics_on_report_id_and_topic_id", unique: true, using: :btree

  create_table "state_languages", force: :cascade do |t|
    t.integer  "geo_state_id"
    t.integer  "language_id"
    t.boolean  "project",      default: false, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "state_languages", ["geo_state_id"], name: "index_state_languages_on_geo_state_id", using: :btree
  add_index "state_languages", ["language_id"], name: "index_state_languages_on_language_id", using: :btree
  add_index "state_languages", ["project"], name: "index_state_languages_on_project", using: :btree

  create_table "sub_districts", force: :cascade do |t|
    t.string   "name",        null: false
    t.integer  "district_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "sub_districts", ["district_id"], name: "index_sub_districts_on_district_id", using: :btree
  add_index "sub_districts", ["name"], name: "index_sub_districts_on_name", using: :btree

  create_table "topics", force: :cascade do |t|
    t.string   "name",                                               null: false
    t.text     "description"
    t.string   "colour",                           default: "white", null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.boolean  "hide_on_alternate_pm_description", default: false,   null: false
    t.integer  "number",                           default: 0,       null: false
  end

  create_table "translatables", force: :cascade do |t|
    t.string   "identifier", null: false
    t.text     "content",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "translatables", ["identifier"], name: "index_translatables_on_identifier", using: :btree

  create_table "translations", force: :cascade do |t|
    t.integer  "translatable_id"
    t.integer  "language_id"
    t.text     "content"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "translations", ["language_id"], name: "index_translations_on_language_id", using: :btree
  add_index "translations", ["translatable_id"], name: "index_translations_on_translatable_id", using: :btree

  create_table "uploaded_files", force: :cascade do |t|
    t.integer  "report_id"
    t.string   "ref",        null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "uploaded_files", ["ref"], name: "index_uploaded_files_on_ref", using: :btree
  add_index "uploaded_files", ["report_id"], name: "index_uploaded_files_on_report_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "phone"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.integer  "mother_tongue_id",                      null: false
    t.integer  "interface_language_id"
    t.string   "otp_secret_key"
    t.string   "email"
    t.boolean  "email_confirmed",       default: false
    t.string   "confirm_token"
    t.boolean  "trusted",               default: false, null: false
    t.boolean  "national",              default: false, null: false
    t.boolean  "admin",                 default: false, null: false
    t.boolean  "national_curator",      default: false, null: false
    t.string   "role_description"
    t.datetime "curator_prompted"
  end

  add_index "users", ["interface_language_id"], name: "index_users_on_interface_language_id", using: :btree
  add_index "users", ["mother_tongue_id"], name: "index_users_on_mother_tongue_id", using: :btree
  add_index "users", ["name"], name: "index_users_on_name", using: :btree
  add_index "users", ["phone"], name: "index_users_on_phone", unique: true, using: :btree

  create_table "zones", force: :cascade do |t|
    t.string   "name",                            null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "pm_description_type", default: 0, null: false
  end

  add_index "zones", ["name"], name: "index_zones_on_name", using: :btree
  add_index "zones", ["pm_description_type"], name: "index_zones_on_pm_description_type", using: :btree

  add_foreign_key "action_points", "events"
  add_foreign_key "action_points", "people", column: "responsible_id"
  add_foreign_key "action_points", "users", column: "record_creator_id"
  add_foreign_key "attendances", "events"
  add_foreign_key "attendances", "people"
  add_foreign_key "creations", "mt_resources"
  add_foreign_key "creations", "people"
  add_foreign_key "curatings", "geo_states"
  add_foreign_key "curatings", "users"
  add_foreign_key "dialects", "languages"
  add_foreign_key "districts", "geo_states"
  add_foreign_key "edits", "users"
  add_foreign_key "edits", "users", column: "curated_by_id"
  add_foreign_key "events", "geo_states"
  add_foreign_key "events", "users"
  add_foreign_key "events_purposes", "events"
  add_foreign_key "events_purposes", "purposes"
  add_foreign_key "external_devices", "users"
  add_foreign_key "finish_line_progresses", "finish_line_markers"
  add_foreign_key "finish_line_progresses", "languages"
  add_foreign_key "geo_states", "zones"
  add_foreign_key "language_names", "languages"
  add_foreign_key "language_progresses", "progress_markers"
  add_foreign_key "language_progresses", "state_languages"
  add_foreign_key "languages", "clusters"
  add_foreign_key "languages", "data_sources", column: "pop_source_id"
  add_foreign_key "languages", "language_families", column: "family_id"
  add_foreign_key "languages", "users", column: "champion_id"
  add_foreign_key "mt_resources", "geo_states"
  add_foreign_key "mt_resources", "languages"
  add_foreign_key "mt_resources", "users"
  add_foreign_key "observations", "people"
  add_foreign_key "observations", "reports"
  add_foreign_key "organisation_engagements", "languages"
  add_foreign_key "organisation_engagements", "organisations"
  add_foreign_key "organisation_translations", "languages"
  add_foreign_key "organisation_translations", "organisations"
  add_foreign_key "organisations", "organisations", column: "parent_id"
  add_foreign_key "output_counts", "geo_states"
  add_foreign_key "output_counts", "languages"
  add_foreign_key "output_counts", "output_tallies"
  add_foreign_key "output_counts", "users"
  add_foreign_key "output_tallies", "topics"
  add_foreign_key "people", "geo_states"
  add_foreign_key "people", "languages"
  add_foreign_key "people", "users"
  add_foreign_key "populations", "languages"
  add_foreign_key "progress_markers", "topics"
  add_foreign_key "progress_updates", "language_progresses"
  add_foreign_key "progress_updates", "users"
  add_foreign_key "reports", "challenge_reports"
  add_foreign_key "reports", "events"
  add_foreign_key "reports", "geo_states"
  add_foreign_key "reports", "impact_reports"
  add_foreign_key "reports", "planning_reports"
  add_foreign_key "reports", "sub_districts"
  add_foreign_key "state_languages", "geo_states"
  add_foreign_key "state_languages", "languages"
  add_foreign_key "sub_districts", "districts"
  add_foreign_key "translations", "languages"
  add_foreign_key "translations", "translatables"
  add_foreign_key "uploaded_files", "reports"
  add_foreign_key "users", "languages", column: "interface_language_id"
end
