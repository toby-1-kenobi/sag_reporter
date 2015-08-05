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
  @me = User.create(
  	  name: 'Andrew',
  	  phone: '7777777777',
  	  password:              'password',
  	  password_confirmation: 'password',
  	  mother_tongue: Language.take,
  	  role: Role.find_by_name('admin')
  	)
  _(@me).wont_be_nil
  _(@me.can_create_event?).must_equal true
end

Given(/^I login$/) do
  visit login_path
  fill_in "Phone", with: @me.phone
  fill_in "Password", with: "password"
  click_on "Log in"
end

When(/^I visit the home page$/) do
  visit root_path
  _(current_path).must_equal root_path
end

Then(/^I see a link to the new event page$/) do
  page.find_link('event-report-link').visible?
end

When(/^I follow the link to the new event page$/) do
  click_on 'event-report-link'
end

Then(/^I am on the new event page$/) do
  _(current_path).must_equal events_new_path
end

Then(/^I see a text field for the event label$/) do
  page.find_field("Event Label").visible?
end

Then(/^I see a date field for the event$/) do
  page.find_field("Date", type: "date").visible?
end

Then(/^I see a textarea for the event location$/) do
  page.find_field("Location", type: "textarea").visible?
end

Then(/^I see a number field for the number of participants$/) do
  page.find_field("event_participant_amount", type: "number").visible?
end

Then(/^I see a text field for a participant name$/) do
  page.find_field("people").visible?
end

Then(/^I see a multi\-select for minority languages$/) do
  page.find_field("Toto", type: "checkbox")
end

Then(/^I see a selectbox for event purpose$/) do
  page.find_field("event_purpose", type: "select").visible?
end

Then(/^I see yes\/no radio buttons for things said at the event$/) do
  page.find_field("mt_society_yes", type: "radio").visible?
  page.find_field("mt_society_no", type: "radio").visible?
end

Then(/^I see a textarea for event content$/) do
  page.find_field("event_content", type: "textarea").visible?
end

When(/^I put text in the participant name field$/) do
  fill_in "people", with: "Fred"
end

Then(/^I see another participant name field$/) do
  page.find_field("people", count: 2)
end

When(/^I click a yes radio button$/) do
  choose "mt_society_yes"
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
