# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#require 'active_record/fixtures'

#ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/db/seed_fixtures", "languages")
#ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/db/seed_fixtures", "permissions")
#ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/db/seed_fixtures", "roles")
#ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/db/seed_fixtures", "topics")
#ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/db/seed_fixtures", "users")

#admin_role = Role.create(name: "admin")
#admin_role.permissions = Permission.all

#User.create!(name:  "admin",
#             phone: "1234567890",
#             password:              "password",
#             password_confirmation: "password",
#             role: admin_role)

require_relative 'fixture_parser'
include FixtureParser

fixtures_dir = "#{Rails.root}/db/seed_fixtures"
test_fixtures_dir = "#{Rails.root}/test/fixtures"
options_hash = {
#	"#{fixtures_dir}/permissions.yml" => { model_name: 'Permission', key_fields: ['name'], update?: true },
#	"#{fixtures_dir}/roles.yml" => { model_name: 'Role', key_fields: ['name'], update?: true },
  "#{fixtures_dir}/zones.yml" => { model_name: 'Zone', key_fields: ['name'], update?: false },
  "#{fixtures_dir}/geo_states.yml" => { model_name: 'GeoState', key_fields: ['name'], update?: true },
# "#{fixtures_dir}/purposes.yml" =>  { model_name: 'Purpose', key_fields: ['name'], update?: true },
  "#{fixtures_dir}/languages.yml" => { model_name: 'Language', key_fields: ['name'], update?: false },
  "#{fixtures_dir}/state_languages.yml" => { model_name: 'StateLanguage', key_fields: ['language', 'geo_state'], update?: true }
# "#{fixtures_dir}/translatables.yml" => { model_name: 'Translatable', key_fields: ['identifier'], update?: true },
# "#{fixtures_dir}/translations.yml" => { model_name: 'Translation', key_fields: ['id'], update?: true },
#	"#{fixtures_dir}/topics.yml" => { model_name: 'Topic', key_fields: ['name'], update?: false },
# "#{fixtures_dir}/progress_markers.yml" => { model_name: 'ProgressMarker', key_fields: ['name'], update?: false }
# "#{fixtures_dir}/output_tallies.yml" => { model_name: 'OutputTally', key_fields: ['name'], update?: true }
# "#{test_fixtures_dir}/language_progresses.yml" => { model_name: 'LanguageProgress', key_fields: nil, update?: true },
# "#{test_fixtures_dir}/progress_updates.yml" => { model_name: 'ProgressUpdate', key_fields: nil, update?: true },
#	"#{fixtures_dir}/users.yml" => { model_name: 'User', key_fields: ['phone'], update?: false }
}
parse_fixtures options_hash

# if there's no admin user, then put a dummy one in
if User.where(role_id: Role.find_by_name('admin')).count == 0
  User.create!(name:  "admin",
             phone: "1234567890",
             password:              "password",
             password_confirmation: "password",
             role: Role.find_by_name('admin'),
             mother_tongue: Language.find_by_name('English'))
end