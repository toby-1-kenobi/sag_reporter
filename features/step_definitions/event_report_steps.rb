require 'active_record/fixtures'

Given(/^seed data is loaded into the database$/) do
  ActiveRecord::FixtureSet.create_fixtures("#{Rails.root}/db/seed_fixtures", "languages")
  _(Language.count).wont_equal 0
  ActiveRecord::FixtureSet.create_fixtures("#{Rails.root}/db/seed_fixtures", "permissions")
  _(Permission.find_by_name('create_event')).wont_be_nil
  ActiveRecord::FixtureSet.create_fixtures("#{Rails.root}/db/seed_fixtures", "roles")
  ActiveRecord::FixtureSet.create_fixtures("#{Rails.root}/db/seed_fixtures", "topics")
  ActiveRecord::FixtureSet.create_fixtures("#{Rails.root}/db/seed_fixtures", "users")
end

Given(/^I am an admin$/) do
  @admin_user = User.create(
  	  name: 'Andrew',
  	  phone: '7777777777',
  	  password:              'password',
  	  password_confirmation: 'password',
  	  mother_tongue: Language.take,
  	  role: Role.find_by_name('admin')
  	)
  _(@admin_user).wont_be_nil
  _(@admin_user.can_create_event?).must_equal true
  log_in_as(@admin_user)
end

When(/^I visit the home page$/) do
  visit root_path
end

Then(/^I see a link to the new event page$/) do
  page.find_link('event-report-link').visible?
end

When(/^I follow the link to the new event page$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I am on the new event page$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I see a text field for the event label$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I see a date field for the event$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I see a textarea for the event location$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I see a number field for the number of participants$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I see a text field for a participant name$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I see some checkbox fields for minority languages$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I see a selectbox for event purpose$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I see yes\/no radio buttons for things said at the event$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I see a textarea for event content$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I put text in the participant name field$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I see another participant name field$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I click a yes radio button$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I see a textarea for the thing said at the event$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I put text in the textarea for the thing said at the event$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I see another textarea for the thing said at the event$/) do
  pending # express the regexp above with the code you wish you had
end
