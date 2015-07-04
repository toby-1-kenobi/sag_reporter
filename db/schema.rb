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

ActiveRecord::Schema.define(version: 20150704065402) do

  create_table "permissions", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "permissions", ["name"], name: "index_permissions_on_name", unique: true

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles_permissions", force: :cascade do |t|
    t.integer  "role_id"
    t.integer  "permission_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "roles_permissions", ["permission_id"], name: "index_roles_permissions_on_permission_id"
  add_index "roles_permissions", ["role_id", "permission_id"], name: "index_roles_permissions_on_role_id_and_permission_id", unique: true
  add_index "roles_permissions", ["role_id"], name: "index_roles_permissions_on_role_id"

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "phone"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.integer  "role_id"
  end

  add_index "users", ["phone"], name: "index_users_on_phone", unique: true
  add_index "users", ["role_id"], name: "index_users_on_role_id"

end
