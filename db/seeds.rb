# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'active_record/fixtures'

ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/db/seed_fixtures", "languages")
ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/db/seed_fixtures", "permissions")
ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/db/seed_fixtures", "roles")
ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/db/seed_fixtures", "topics")
ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/db/seed_fixtures", "users")

#admin_role = Role.create(name: "admin")
#admin_role.permissions = Permission.all

#User.create!(name:  "admin",
#             phone: "1234567890",
#             password:              "password",
#             password_confirmation: "password",
#             role: admin_role)
