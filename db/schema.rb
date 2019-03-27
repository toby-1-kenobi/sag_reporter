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

ActiveRecord::Schema.define(version: 20190327102509) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "aggregate_ministry_outputs", force: :cascade do |t|
    t.string   "month",             null: false
    t.integer  "value",             null: false
    t.boolean  "actual",            null: false
    t.integer  "creator_id",        null: false
    t.text     "comment"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "state_language_id", null: false
    t.integer  "deliverable_id",    null: false
  end

  add_index "aggregate_ministry_outputs", ["creator_id"], name: "index_aggregate_ministry_outputs_on_creator_id", using: :btree
  add_index "aggregate_ministry_outputs", ["deliverable_id"], name: "index_aggregate_ministry_outputs_on_deliverable_id", using: :btree
  add_index "aggregate_ministry_outputs", ["state_language_id"], name: "index_aggregate_ministry_outputs_on_state_language_id", using: :btree

  create_table "bible_passages", force: :cascade do |t|
    t.integer  "church_ministry_id", null: false
    t.integer  "chapter_id",         null: false
    t.string   "month",              null: false
    t.integer  "verse",              null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "bible_passages", ["chapter_id"], name: "index_bible_passages_on_chapter_id", using: :btree
  add_index "bible_passages", ["church_ministry_id"], name: "index_bible_passages_on_church_ministry_id", using: :btree

  create_table "books", force: :cascade do |t|
    t.string   "name",         null: false
    t.string   "abbreviation", null: false
    t.integer  "number",       null: false
    t.boolean  "nt",           null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "books", ["nt"], name: "index_books_on_nt", using: :btree
  add_index "books", ["number"], name: "index_books_on_number", using: :btree

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

  create_table "chapters", force: :cascade do |t|
    t.integer  "book_id"
    t.integer  "number",     null: false
    t.integer  "verses",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "chapters", ["book_id"], name: "index_chapters_on_book_id", using: :btree
  add_index "chapters", ["number"], name: "index_chapters_on_number", using: :btree

  create_table "church_ministries", force: :cascade do |t|
    t.integer  "church_team_id",             null: false
    t.integer  "ministry_id",                null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "status",         default: 0, null: false
    t.integer  "facilitator_id"
  end

  add_index "church_ministries", ["church_team_id"], name: "index_church_ministries_on_church_team_id", using: :btree
  add_index "church_ministries", ["facilitator_id"], name: "index_church_ministries_on_facilitator_id", using: :btree
  add_index "church_ministries", ["ministry_id"], name: "index_church_ministries_on_ministry_id", using: :btree

  create_table "church_team_memberships", force: :cascade do |t|
    t.integer  "user_id",        null: false
    t.integer  "church_team_id", null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "church_team_memberships", ["church_team_id"], name: "index_church_team_memberships_on_church_team_id", using: :btree
  add_index "church_team_memberships", ["user_id", "church_team_id"], name: "index_church_team_user", unique: true, using: :btree
  add_index "church_team_memberships", ["user_id"], name: "index_church_team_memberships_on_user_id", using: :btree

  create_table "church_teams", force: :cascade do |t|
    t.string   "name"
    t.integer  "organisation_id"
    t.string   "leader",                        null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "state_language_id",             null: false
    t.integer  "status",            default: 0, null: false
  end

  add_index "church_teams", ["leader", "state_language_id", "organisation_id"], name: "index_church_team_unique", unique: true, using: :btree
  add_index "church_teams", ["leader", "state_language_id"], name: "index_church_team_unique_org_null", unique: true, where: "(organisation_id IS NULL)", using: :btree
  add_index "church_teams", ["leader"], name: "index_church_teams_on_leader", using: :btree
  add_index "church_teams", ["organisation_id"], name: "index_church_teams_on_organisation_id", using: :btree
  add_index "church_teams", ["state_language_id"], name: "index_church_teams_on_state_language_id", using: :btree

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

  create_table "deliverables", force: :cascade do |t|
    t.integer  "ministry_id",                       null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "number",                            null: false
    t.integer  "calculation_method", default: 0,    null: false
    t.integer  "reporter",           default: 0,    null: false
    t.integer  "short_form_id",                     null: false
    t.integer  "plan_form_id",                      null: false
    t.integer  "result_form_id",                    null: false
    t.boolean  "funder_interest",    default: true, null: false
    t.integer  "ui_order"
  end

  add_index "deliverables", ["ministry_id"], name: "index_deliverables_on_ministry_id", using: :btree
  add_index "deliverables", ["number", "ministry_id"], name: "index_deliverables_number_ministry", unique: true, using: :btree
  add_index "deliverables", ["plan_form_id"], name: "index_deliverables_on_plan_form_id", using: :btree
  add_index "deliverables", ["result_form_id"], name: "index_deliverables_on_result_form_id", using: :btree
  add_index "deliverables", ["short_form_id"], name: "index_deliverables_on_short_form_id", using: :btree

  create_table "dialects", force: :cascade do |t|
    t.integer  "language_id", null: false
    t.string   "name",        null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "dialects", ["language_id", "name"], name: "language_dialect_names", unique: true, using: :btree
  add_index "dialects", ["language_id"], name: "index_dialects_on_language_id", using: :btree
  add_index "dialects", ["name"], name: "index_dialects_on_name", using: :btree

  create_table "distribution_methods", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "distribution_methods", ["name"], name: "index_distribution_methods_on_name", using: :btree

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

  create_table "external_devices", force: :cascade do |t|
    t.string   "device_id"
    t.string   "name"
    t.boolean  "registered",  default: false, null: false
    t.integer  "user_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "app_version"
  end

  add_index "external_devices", ["user_id"], name: "index_external_devices_on_user_id", using: :btree

  create_table "facilitator_feedbacks", force: :cascade do |t|
    t.integer  "church_ministry_id",                    null: false
    t.string   "month",                                 null: false
    t.text     "plan_feedback"
    t.integer  "plan_team_member_id"
    t.text     "plan_response"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.text     "facilitator_plan"
    t.text     "result_feedback"
    t.text     "result_response"
    t.integer  "result_team_member_id"
    t.integer  "progress"
    t.boolean  "report_approved",       default: false, null: false
  end

  add_index "facilitator_feedbacks", ["church_ministry_id"], name: "index_facilitator_feedbacks_on_church_ministry_id", using: :btree
  add_index "facilitator_feedbacks", ["month"], name: "index_facilitator_feedbacks_on_month", using: :btree
  add_index "facilitator_feedbacks", ["plan_team_member_id"], name: "index_facilitator_feedbacks_on_plan_team_member_id", using: :btree
  add_index "facilitator_feedbacks", ["result_team_member_id"], name: "index_facilitator_feedbacks_on_result_team_member_id", using: :btree

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
    t.integer  "year"
  end

  add_index "finish_line_progresses", ["finish_line_marker_id"], name: "index_finish_line_progresses_on_finish_line_marker_id", using: :btree
  add_index "finish_line_progresses", ["language_id", "finish_line_marker_id", "year"], name: "index_lang_finish_line", unique: true, using: :btree
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

  create_table "language_streams", force: :cascade do |t|
    t.integer  "ministry_id",       null: false
    t.integer  "state_language_id", null: false
    t.integer  "facilitator_id"
    t.integer  "project_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "sub_project_id"
  end

  add_index "language_streams", ["facilitator_id"], name: "index_language_streams_on_facilitator_id", using: :btree
  add_index "language_streams", ["ministry_id", "state_language_id", "facilitator_id", "project_id"], name: "index_ministry_language_facilitator_project", unique: true, using: :btree
  add_index "language_streams", ["ministry_id"], name: "index_language_streams_on_ministry_id", using: :btree
  add_index "language_streams", ["project_id"], name: "index_language_streams_on_project_id", using: :btree
  add_index "language_streams", ["state_language_id"], name: "index_language_streams_on_state_language_id", using: :btree
  add_index "language_streams", ["sub_project_id"], name: "index_language_streams_on_sub_project_id", using: :btree

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
    t.integer  "sensitivity",                         default: 1,       null: false
    t.integer  "egids"
    t.string   "pseudonym"
  end

  add_index "languages", ["champion_id"], name: "index_languages_on_champion_id", using: :btree
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

  create_table "ministries", force: :cascade do |t|
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "topic_id",      default: 1, null: false
    t.string   "code"
    t.integer  "name_id",                   null: false
    t.integer  "short_form_id",             null: false
  end

  add_index "ministries", ["name_id"], name: "index_ministries_on_name_id", using: :btree
  add_index "ministries", ["short_form_id"], name: "index_ministries_on_short_form_id", using: :btree
  add_index "ministries", ["topic_id"], name: "index_ministries_on_topic_id", using: :btree

  create_table "ministry_outputs", force: :cascade do |t|
    t.integer  "deliverable_id",     null: false
    t.string   "month",              null: false
    t.integer  "value",              null: false
    t.boolean  "actual",             null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "church_ministry_id", null: false
    t.integer  "creator_id",         null: false
    t.text     "comment"
  end

  add_index "ministry_outputs", ["actual"], name: "index_ministry_outputs_on_actual", using: :btree
  add_index "ministry_outputs", ["church_ministry_id"], name: "index_ministry_outputs_on_church_ministry_id", using: :btree
  add_index "ministry_outputs", ["creator_id"], name: "index_ministry_outputs_on_creator_id", using: :btree
  add_index "ministry_outputs", ["deliverable_id"], name: "index_ministry_outputs_on_deliverable_id", using: :btree
  add_index "ministry_outputs", ["month"], name: "index_ministry_outputs_on_month", using: :btree

  create_table "mt_resources", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name",                           null: false
    t.text     "description"
    t.integer  "language_id",                    null: false
    t.boolean  "cc_share_alike", default: false, null: false
    t.integer  "medium",                         null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "status",         default: 0,     null: false
    t.integer  "publish_year"
    t.string   "url"
    t.text     "how_to_access"
    t.integer  "geo_state_id"
  end

  add_index "mt_resources", ["created_at"], name: "index_mt_resources_on_created_at", using: :btree
  add_index "mt_resources", ["geo_state_id"], name: "index_mt_resources_on_geo_state_id", using: :btree
  add_index "mt_resources", ["language_id"], name: "index_mt_resources_on_language_id", using: :btree
  add_index "mt_resources", ["medium"], name: "index_mt_resources_on_medium", using: :btree
  add_index "mt_resources", ["publish_year"], name: "index_mt_resources_on_publish_year", using: :btree
  add_index "mt_resources", ["user_id"], name: "index_mt_resources_on_user_id", using: :btree

  create_table "mt_resources_product_categories", id: false, force: :cascade do |t|
    t.integer "mt_resource_id",      null: false
    t.integer "product_category_id", null: false
  end

  add_index "mt_resources_product_categories", ["mt_resource_id", "product_category_id"], name: "index_resource_category", unique: true, using: :btree

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
    t.string   "name",                         null: false
    t.string   "abbreviation"
    t.integer  "parent_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "church",       default: false, null: false
  end

  add_index "organisations", ["abbreviation"], name: "index_organisations_on_abbreviation", unique: true, using: :btree
  add_index "organisations", ["name"], name: "index_organisations_on_name", unique: true, using: :btree

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

  create_table "phone_messages", force: :cascade do |t|
    t.integer  "user_id",        null: false
    t.text     "content",        null: false
    t.datetime "sent_at"
    t.text     "error_messages"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.datetime "expiration"
  end

  add_index "phone_messages", ["sent_at"], name: "index_phone_messages_on_sent_at", using: :btree
  add_index "phone_messages", ["user_id"], name: "index_phone_messages_on_user_id", using: :btree

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

  create_table "product_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "number",     null: false
    t.integer  "name_id",    null: false
  end

  add_index "product_categories", ["name_id"], name: "index_product_categories_on_name_id", using: :btree

  create_table "product_categories_tools", id: false, force: :cascade do |t|
    t.integer "tool_id",             null: false
    t.integer "product_category_id", null: false
  end

  add_index "product_categories_tools", ["tool_id", "product_category_id"], name: "index_tools_product_categories_on_t_and_pc", unique: true, using: :btree

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

  create_table "project_languages", force: :cascade do |t|
    t.integer  "project_id",         null: false
    t.integer  "state_language_id",  null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "churches_reported"
    t.integer  "people_in_churches"
    t.text     "followup_contact"
  end

  add_index "project_languages", ["project_id", "state_language_id"], name: "index_project_language", unique: true, using: :btree
  add_index "project_languages", ["project_id"], name: "index_project_languages_on_project_id", using: :btree
  add_index "project_languages", ["state_language_id"], name: "index_project_languages_on_state_language_id", using: :btree

  create_table "project_progresses", force: :cascade do |t|
    t.integer  "project_stream_id",                 null: false
    t.string   "month",                             null: false
    t.integer  "progress"
    t.text     "comment"
    t.boolean  "approved",          default: false, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "project_progresses", ["month"], name: "index_project_progresses_on_month", using: :btree
  add_index "project_progresses", ["project_stream_id"], name: "index_project_progresses_on_project_stream_id", using: :btree

  create_table "project_streams", force: :cascade do |t|
    t.integer  "project_id",                null: false
    t.integer  "ministry_id",               null: false
    t.integer  "supervisor_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "stage",         default: 0, null: false
  end

  add_index "project_streams", ["ministry_id"], name: "index_project_streams_on_ministry_id", using: :btree
  add_index "project_streams", ["project_id", "ministry_id"], name: "index_project_ministry", unique: true, using: :btree
  add_index "project_streams", ["project_id"], name: "index_project_streams_on_project_id", using: :btree
  add_index "project_streams", ["supervisor_id"], name: "index_project_streams_on_supervisor_id", using: :btree

  create_table "project_supervisors", force: :cascade do |t|
    t.integer  "project_id", null: false
    t.integer  "user_id",    null: false
    t.integer  "role",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "project_supervisors", ["project_id", "user_id", "role"], name: "index_project_supervisor_role", unique: true, using: :btree
  add_index "project_supervisors", ["project_id"], name: "index_project_supervisors_on_project_id", using: :btree
  add_index "project_supervisors", ["user_id"], name: "index_project_supervisors_on_user_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "projects", ["name"], name: "index_projects_on_name", using: :btree

  create_table "quarterly_evaluations", force: :cascade do |t|
    t.integer  "project_id",                        null: false
    t.integer  "sub_project_id"
    t.integer  "state_language_id",                 null: false
    t.integer  "ministry_id",                       null: false
    t.string   "quarter",                           null: false
    t.text     "comment"
    t.text     "question_1"
    t.text     "question_2"
    t.text     "question_3"
    t.text     "question_4"
    t.integer  "progress"
    t.integer  "report_id"
    t.boolean  "approved",          default: false, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.text     "improvements"
  end

  add_index "quarterly_evaluations", ["ministry_id"], name: "index_quarterly_evaluations_on_ministry_id", using: :btree
  add_index "quarterly_evaluations", ["project_id"], name: "index_quarterly_evaluations_on_project_id", using: :btree
  add_index "quarterly_evaluations", ["quarter"], name: "index_quarterly_evaluations_on_quarter", using: :btree
  add_index "quarterly_evaluations", ["report_id"], name: "index_quarterly_evaluations_on_report_id", using: :btree
  add_index "quarterly_evaluations", ["state_language_id"], name: "index_quarterly_evaluations_on_state_language_id", using: :btree
  add_index "quarterly_evaluations", ["sub_project_id"], name: "index_quarterly_evaluations_on_sub_project_id", using: :btree

  create_table "quarterly_targets", force: :cascade do |t|
    t.integer  "state_language_id", null: false
    t.integer  "deliverable_id",    null: false
    t.string   "quarter",           null: false
    t.integer  "value",             null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "quarterly_targets", ["deliverable_id"], name: "index_quarterly_targets_on_deliverable_id", using: :btree
  add_index "quarterly_targets", ["state_language_id", "deliverable_id", "quarter"], name: "index_language_deliverable_quarter", unique: true, using: :btree
  add_index "quarterly_targets", ["state_language_id"], name: "index_quarterly_targets_on_state_language_id", using: :btree

  create_table "registration_approvals", force: :cascade do |t|
    t.integer  "registering_user_id", null: false
    t.integer  "approver_id",         null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "registration_approvals", ["approver_id"], name: "index_registration_approvals_on_approver_id", using: :btree
  add_index "registration_approvals", ["registering_user_id", "approver_id"], name: "index_registering_user_approver", unique: true, using: :btree
  add_index "registration_approvals", ["registering_user_id"], name: "index_registration_approvals_on_registering_user_id", using: :btree

  create_table "report_streams", force: :cascade do |t|
    t.integer  "report_id",   null: false
    t.integer  "ministry_id", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "report_streams", ["ministry_id"], name: "index_report_streams_on_ministry_id", using: :btree
  add_index "report_streams", ["report_id", "ministry_id"], name: "index_report_ministry", unique: true, using: :btree
  add_index "report_streams", ["report_id"], name: "index_report_streams_on_report_id", using: :btree

  create_table "reports", force: :cascade do |t|
    t.integer  "reporter_id",                             null: false
    t.text     "content",                                 null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "mt_society"
    t.boolean  "mt_church"
    t.boolean  "needs_society"
    t.boolean  "needs_church"
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
    t.integer  "project_id"
    t.integer  "church_team_id"
  end

  add_index "reports", ["challenge_report_id"], name: "index_reports_on_challenge_report_id", using: :btree
  add_index "reports", ["church_team_id"], name: "index_reports_on_church_team_id", using: :btree
  add_index "reports", ["geo_state_id"], name: "index_reports_on_geo_state_id", using: :btree
  add_index "reports", ["impact_report_id"], name: "index_reports_on_impact_report_id", using: :btree
  add_index "reports", ["planning_report_id"], name: "index_reports_on_planning_report_id", using: :btree
  add_index "reports", ["project_id"], name: "index_reports_on_project_id", using: :btree
  add_index "reports", ["report_date"], name: "index_reports_on_report_date", using: :btree
  add_index "reports", ["reporter_id"], name: "index_reports_on_reporter_id", using: :btree
  add_index "reports", ["status"], name: "index_reports_on_status", using: :btree
  add_index "reports", ["sub_district_id"], name: "index_reports_on_sub_district_id", using: :btree

  create_table "reports_topics", id: false, force: :cascade do |t|
    t.integer "report_id"
    t.integer "topic_id"
  end

  add_index "reports_topics", ["report_id", "topic_id"], name: "index_reports_topics_on_report_id_and_topic_id", unique: true, using: :btree

  create_table "sign_of_transformation_markers", force: :cascade do |t|
    t.integer  "name_id",     null: false
    t.integer  "ministry_id", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "sign_of_transformation_markers", ["ministry_id"], name: "index_sign_of_transformation_markers_on_ministry_id", using: :btree
  add_index "sign_of_transformation_markers", ["name_id"], name: "index_sign_of_transformation_markers_on_name_id", using: :btree

  create_table "sign_of_transformations", force: :cascade do |t|
    t.integer  "church_ministry_id", null: false
    t.string   "month",              null: false
    t.string   "other"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "marker_id"
  end

  add_index "sign_of_transformations", ["church_ministry_id"], name: "index_sign_of_transformations_on_church_ministry_id", using: :btree
  add_index "sign_of_transformations", ["marker_id"], name: "index_sign_of_transformations_on_marker_id", using: :btree

  create_table "state_languages", force: :cascade do |t|
    t.integer  "geo_state_id"
    t.integer  "language_id"
    t.boolean  "project",      default: false, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "primary",      default: false, null: false
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

  create_table "sub_projects", force: :cascade do |t|
    t.string   "name",       null: false
    t.integer  "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sub_projects", ["name", "project_id"], name: "index_sub_projects_on_name_and_project_id", unique: true, using: :btree
  add_index "sub_projects", ["name"], name: "index_sub_projects_on_name", using: :btree
  add_index "sub_projects", ["project_id"], name: "index_sub_projects_on_project_id", using: :btree

  create_table "supervisor_feedbacks", force: :cascade do |t|
    t.integer  "facilitator_id",                       null: false
    t.string   "month",                                null: false
    t.text     "plan_feedback"
    t.text     "plan_response"
    t.text     "result_feedback"
    t.integer  "facilitator_progress"
    t.integer  "project_progress"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "ministry_id",                          null: false
    t.integer  "supervisor_id",                        null: false
    t.boolean  "report_approved",      default: false, null: false
    t.integer  "state_language_id",                    null: false
  end

  add_index "supervisor_feedbacks", ["facilitator_id"], name: "index_supervisor_feedbacks_on_facilitator_id", using: :btree
  add_index "supervisor_feedbacks", ["ministry_id", "state_language_id", "facilitator_id", "month"], name: "index_supervisor_feedbacks_uniqueness", unique: true, using: :btree
  add_index "supervisor_feedbacks", ["ministry_id"], name: "index_supervisor_feedbacks_on_ministry_id", using: :btree
  add_index "supervisor_feedbacks", ["state_language_id"], name: "index_supervisor_feedbacks_on_state_language_id", using: :btree
  add_index "supervisor_feedbacks", ["supervisor_id"], name: "index_supervisor_feedbacks_on_supervisor_id", using: :btree

  create_table "tools", force: :cascade do |t|
    t.integer  "language_id",                       null: false
    t.integer  "creator_id",                        null: false
    t.text     "url",                               null: false
    t.text     "description",                       null: false
    t.integer  "status",                default: 0, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "finish_line_marker_id"
  end

  add_index "tools", ["creator_id"], name: "index_tools_on_creator_id", using: :btree
  add_index "tools", ["finish_line_marker_id"], name: "index_tools_on_finish_line_marker_id", using: :btree
  add_index "tools", ["language_id"], name: "index_tools_on_language_id", using: :btree

  create_table "topics", force: :cascade do |t|
    t.string   "name",                                               null: false
    t.text     "description"
    t.string   "colour",                           default: "white", null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.boolean  "hide_on_alternate_pm_description", default: false,   null: false
    t.integer  "number",                           default: 0,       null: false
  end

  create_table "translation_codes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "translation_distributions", force: :cascade do |t|
    t.integer  "distribution_method_id", null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "translation_project_id", null: false
  end

  add_index "translation_distributions", ["distribution_method_id", "translation_project_id"], name: "index_translation_distribution_uniq", unique: true, using: :btree
  add_index "translation_distributions", ["distribution_method_id"], name: "index_translation_distributions_on_distribution_method_id", using: :btree
  add_index "translation_distributions", ["translation_project_id"], name: "index_translation_distributions_on_translation_project_id", using: :btree

  create_table "translation_progresses", force: :cascade do |t|
    t.integer  "chapter_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "deliverable_id",                     null: false
    t.integer  "translation_method",     default: 0, null: false
    t.integer  "translation_tool",       default: 0, null: false
    t.string   "month"
    t.integer  "translation_project_id",             null: false
  end

  add_index "translation_progresses", ["chapter_id", "translation_project_id", "deliverable_id"], name: "index_translation_progress_unique", unique: true, using: :btree
  add_index "translation_progresses", ["chapter_id"], name: "index_translation_progresses_on_chapter_id", using: :btree
  add_index "translation_progresses", ["deliverable_id"], name: "index_translation_progresses_on_deliverable_id", using: :btree
  add_index "translation_progresses", ["translation_project_id"], name: "index_translation_progresses_on_translation_project_id", using: :btree

  create_table "translation_projects", force: :cascade do |t|
    t.integer  "language_id"
    t.text     "office_location"
    t.text     "survey_findings"
    t.text     "orthography_notes"
    t.string   "publisher"
    t.string   "copyright"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "project_id",        null: false
  end

  add_index "translation_projects", ["language_id", "project_id"], name: "index_translation_projects_unique", unique: true, using: :btree
  add_index "translation_projects", ["language_id"], name: "index_translation_projects_on_language_id", using: :btree
  add_index "translation_projects", ["project_id"], name: "index_translation_projects_on_project_id", using: :btree

  create_table "translations", force: :cascade do |t|
    t.integer  "language_id",                         null: false
    t.text     "content",                             null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "translation_code_id",                 null: false
    t.string   "key"
    t.string   "locale"
    t.text     "value"
    t.string   "interpolations"
    t.boolean  "is_proc",             default: false, null: false
  end

  add_index "translations", ["language_id", "translation_code_id"], name: "index_language_translation_code", unique: true, using: :btree
  add_index "translations", ["language_id"], name: "index_translations_on_language_id", using: :btree
  add_index "translations", ["translation_code_id"], name: "index_translations_on_translation_code_id", using: :btree

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
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.integer  "mother_tongue_id"
    t.integer  "interface_language_id"
    t.string   "otp_secret_key"
    t.string   "email"
    t.boolean  "email_confirmed",          default: false
    t.string   "confirm_token"
    t.boolean  "trusted",                  default: false,        null: false
    t.boolean  "national",                 default: false,        null: false
    t.boolean  "admin",                    default: false,        null: false
    t.boolean  "national_curator",         default: false,        null: false
    t.string   "role_description"
    t.datetime "curator_prompted"
    t.boolean  "lci_board_member",         default: false,        null: false
    t.boolean  "lci_agency_leader",        default: false,        null: false
    t.boolean  "reset_password",           default: false
    t.string   "reset_password_token"
    t.boolean  "forward_planning_curator", default: false,        null: false
    t.integer  "registration_status",      default: 2,            null: false
    t.boolean  "zone_admin",               default: false,        null: false
    t.string   "organisation"
    t.date     "user_last_login_dt",       default: '2018-10-20'
    t.datetime "password_changed",                                null: false
  end

  add_index "users", ["interface_language_id"], name: "index_users_on_interface_language_id", using: :btree
  add_index "users", ["mother_tongue_id"], name: "index_users_on_mother_tongue_id", using: :btree
  add_index "users", ["name"], name: "index_users_on_name", using: :btree
  add_index "users", ["phone"], name: "index_users_on_phone", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "zones", force: :cascade do |t|
    t.string   "name",                            null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "pm_description_type", default: 0, null: false
  end

  add_index "zones", ["name"], name: "index_zones_on_name", using: :btree
  add_index "zones", ["pm_description_type"], name: "index_zones_on_pm_description_type", using: :btree

  add_foreign_key "aggregate_ministry_outputs", "deliverables"
  add_foreign_key "aggregate_ministry_outputs", "state_languages"
  add_foreign_key "aggregate_ministry_outputs", "users", column: "creator_id"
  add_foreign_key "bible_passages", "chapters"
  add_foreign_key "bible_passages", "church_ministries"
  add_foreign_key "chapters", "books"
  add_foreign_key "church_ministries", "church_teams"
  add_foreign_key "church_ministries", "ministries"
  add_foreign_key "church_ministries", "users", column: "facilitator_id"
  add_foreign_key "church_team_memberships", "church_teams"
  add_foreign_key "church_team_memberships", "users"
  add_foreign_key "church_teams", "organisations"
  add_foreign_key "church_teams", "state_languages"
  add_foreign_key "creations", "mt_resources"
  add_foreign_key "creations", "people"
  add_foreign_key "curatings", "geo_states"
  add_foreign_key "curatings", "users"
  add_foreign_key "deliverables", "ministries"
  add_foreign_key "deliverables", "translation_codes", column: "plan_form_id"
  add_foreign_key "deliverables", "translation_codes", column: "result_form_id"
  add_foreign_key "deliverables", "translation_codes", column: "short_form_id"
  add_foreign_key "dialects", "languages"
  add_foreign_key "districts", "geo_states"
  add_foreign_key "edits", "users"
  add_foreign_key "edits", "users", column: "curated_by_id"
  add_foreign_key "external_devices", "users"
  add_foreign_key "facilitator_feedbacks", "church_ministries"
  add_foreign_key "facilitator_feedbacks", "users", column: "plan_team_member_id"
  add_foreign_key "facilitator_feedbacks", "users", column: "result_team_member_id"
  add_foreign_key "finish_line_progresses", "finish_line_markers"
  add_foreign_key "finish_line_progresses", "languages"
  add_foreign_key "geo_states", "zones"
  add_foreign_key "language_names", "languages"
  add_foreign_key "language_progresses", "progress_markers"
  add_foreign_key "language_progresses", "state_languages"
  add_foreign_key "language_streams", "ministries"
  add_foreign_key "language_streams", "projects"
  add_foreign_key "language_streams", "state_languages"
  add_foreign_key "language_streams", "sub_projects"
  add_foreign_key "language_streams", "users", column: "facilitator_id"
  add_foreign_key "languages", "data_sources", column: "pop_source_id"
  add_foreign_key "languages", "language_families", column: "family_id"
  add_foreign_key "languages", "users", column: "champion_id"
  add_foreign_key "ministries", "topics"
  add_foreign_key "ministries", "translation_codes", column: "name_id"
  add_foreign_key "ministries", "translation_codes", column: "short_form_id"
  add_foreign_key "ministry_outputs", "church_ministries"
  add_foreign_key "ministry_outputs", "deliverables"
  add_foreign_key "ministry_outputs", "users", column: "creator_id"
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
  add_foreign_key "people", "geo_states"
  add_foreign_key "people", "languages"
  add_foreign_key "people", "users"
  add_foreign_key "phone_messages", "users"
  add_foreign_key "populations", "languages"
  add_foreign_key "product_categories", "translation_codes", column: "name_id"
  add_foreign_key "progress_markers", "topics"
  add_foreign_key "progress_updates", "language_progresses"
  add_foreign_key "progress_updates", "users"
  add_foreign_key "project_languages", "projects"
  add_foreign_key "project_languages", "state_languages"
  add_foreign_key "project_progresses", "project_streams"
  add_foreign_key "project_streams", "ministries"
  add_foreign_key "project_streams", "projects"
  add_foreign_key "project_streams", "users", column: "supervisor_id"
  add_foreign_key "project_supervisors", "projects"
  add_foreign_key "project_supervisors", "users"
  add_foreign_key "quarterly_evaluations", "ministries"
  add_foreign_key "quarterly_evaluations", "projects"
  add_foreign_key "quarterly_evaluations", "reports"
  add_foreign_key "quarterly_evaluations", "state_languages"
  add_foreign_key "quarterly_evaluations", "sub_projects"
  add_foreign_key "quarterly_targets", "deliverables"
  add_foreign_key "quarterly_targets", "state_languages"
  add_foreign_key "registration_approvals", "users", column: "approver_id"
  add_foreign_key "registration_approvals", "users", column: "registering_user_id"
  add_foreign_key "report_streams", "ministries"
  add_foreign_key "report_streams", "reports"
  add_foreign_key "reports", "challenge_reports"
  add_foreign_key "reports", "church_teams"
  add_foreign_key "reports", "geo_states"
  add_foreign_key "reports", "impact_reports"
  add_foreign_key "reports", "planning_reports"
  add_foreign_key "reports", "projects"
  add_foreign_key "reports", "sub_districts"
  add_foreign_key "sign_of_transformation_markers", "ministries"
  add_foreign_key "sign_of_transformation_markers", "translation_codes", column: "name_id"
  add_foreign_key "sign_of_transformations", "church_ministries"
  add_foreign_key "sign_of_transformations", "sign_of_transformation_markers", column: "marker_id"
  add_foreign_key "state_languages", "geo_states"
  add_foreign_key "state_languages", "languages"
  add_foreign_key "sub_districts", "districts"
  add_foreign_key "sub_projects", "projects"
  add_foreign_key "supervisor_feedbacks", "ministries"
  add_foreign_key "supervisor_feedbacks", "state_languages"
  add_foreign_key "supervisor_feedbacks", "users", column: "facilitator_id"
  add_foreign_key "tools", "finish_line_markers"
  add_foreign_key "tools", "languages"
  add_foreign_key "tools", "users", column: "creator_id"
  add_foreign_key "translation_distributions", "distribution_methods"
  add_foreign_key "translation_distributions", "translation_projects"
  add_foreign_key "translation_progresses", "chapters"
  add_foreign_key "translation_progresses", "deliverables"
  add_foreign_key "translation_progresses", "translation_projects"
  add_foreign_key "translation_projects", "languages"
  add_foreign_key "translation_projects", "projects"
  add_foreign_key "translations", "languages"
  add_foreign_key "translations", "translation_codes"
  add_foreign_key "uploaded_files", "reports"
  add_foreign_key "users", "languages", column: "interface_language_id"
end
