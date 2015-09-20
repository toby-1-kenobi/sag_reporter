require 'active_record/fixtures'

Given(/^(.*) data is loaded into the database$/) do |fixture_file|
  case fixture_file
  when "seed", "all", "all seed"
    steps %{
      Given zones data is loaded into the database
      Given geo_states data is loaded into the database
      Given languages data is loaded into the database
      Given permissions data is loaded into the database
      Given roles data is loaded into the database
      Given topics data is loaded into the database
      Given users data is loaded into the database
      Given translatables data is loaded into the database
      Given translations data is loaded into the database
    }
    _(Language.count).wont_equal 0
  else
    ActiveRecord::FixtureSet.create_fixtures("#{Rails.root}/db/seed_fixtures", fixture_file)
  end
end

Given (/^I login as(?: an)? admin$/) do
  steps %{
    Given I am an admin
    Given I login
  }
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
	page.find("body")
  _(current_path).must_equal events_new_path
end

Then(/^I see a text field for the event label$/) do
  page.find_field("Event Label").visible?
end

Then(/^I see a date field for the event$/) do
  page.find_field("event_event_date", type: "date").visible?
end

Then(/^I see a textarea for the event location$/) do
  page.find_field("Location", type: "textarea").visible?
end

Then(/^I see a number field for the number of participants$/) do
  page.find_field("event_participant_amount", type: "number").visible?
end

Then(/^I see a text field for a participant name$/) do
  page.find_field("people", type: "text")
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
  page.find("mt_society_response").visible?
end

When(/^I click a no radio button$/) do
  choose "mt_society_no"
end

Then(/^I cannot see a textarea for the thing said at the event$/) do
  page.find("mt_society_response").not_visible?
end

When(/^I put text in the textarea for the thing said at the event$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I see another textarea for the thing said at the event$/) do
  pending # express the regexp above with the code you wish you had
end
