# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require_relative 'fixture_parser'
include FixtureParser

fixtures_dir = "#{Rails.root}/db/seed_fixtures"

options_hash = {
  "#{fixtures_dir}/zones.yml" => { model_name: 'Zone', key_fields: ['name'], update?: false },
  "#{fixtures_dir}/geo_states.yml" => { model_name: 'GeoState', key_fields: ['name'], update?: false },
  "#{fixtures_dir}/language_families.yml" => { model_name: 'Language', key_fields: ['name'], update?: false },
  "#{fixtures_dir}/languages.yml" => { model_name: 'Language', key_fields: ['name'], update?: false },
  "#{fixtures_dir}/state_languages.yml" => { model_name: 'StateLanguage', key_fields: ['language', 'geo_state'], update?: false },
  "#{fixtures_dir}/organisations.yml" => { model_name: 'Organisation', key_fields: ['name'], update?: false },
	"#{fixtures_dir}/topics.yml" => { model_name: 'Topic', key_fields: ['name'], update?: false },
  "#{fixtures_dir}/progress_markers.yml" => { model_name: 'ProgressMarker', key_fields: ['name'], update?: false },
  "#{fixtures_dir}/finish_line_markers.yml" => { model_name: 'FinishLineMarker', key_fields: ['name'], update?: false },
  "#{fixtures_dir}/translatables.yml" => { model_name: 'Translatable', key_fields: ['identifier'], update?: false },
  "#{fixtures_dir}/translations.yml" => { model_name: 'Translation', key_fields: ['translatable', 'language'], update?: false }
# "#{fixtures_dir}/output_tallies.yml" => { model_name: 'OutputTally', key_fields: ['name'], update?: false },
# "#{fixtures_dir}/purposes.yml" =>  { model_name: 'Purpose', key_fields: ['name'], update?: false },
# "#{fixtures_dir}/users.yml" => { model_name: 'User', key_fields: ['phone'], update?: false }
}
parse_fixtures options_hash

# if there's no admin user, then put a dummy one in
if User.where(role_id: Role.find_by_name('admin')).count == 0
  puts 'creating admin user'
  admin_user = User.new(name: 'admin',
             phone: '1234567890',
             password: 'password',
             password_confirmation: 'password',
             role: Role.find_by_name('admin'),
             mother_tongue: Language.find_by_name('English'))
  admin_user.geo_states << GeoState.take
  if admin_user.save
    puts "phone: #{admin_user.phone} password: password"
  else
    puts 'Could not create admin user'
  end
end

require_relative 'location_import'
require_relative 'language_data_import'
require_relative 'losa_import'
