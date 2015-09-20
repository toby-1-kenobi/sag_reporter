

When(/^I visit the new user page$/) do
  visit new_user_path
  _(current_path).must_equal new_user_path
end

Then(/^the state selector has no states$/) do
  page.wont_have_selector("#user-geo_states-dropdown .geo_states-option", :visible)
  #refute_selector("#user-geo_states-dropdown .geo_states-option", :visible)
end

Then(/^there is a zone selector$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I select the zone north_east$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the state selector (has|does not have) the states (.*)$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I select the zone hindi_zone$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I unselect the zone north_east$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I select the states bihar and up$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I complete the user form$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I submit the form$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I am on the user page$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I see bihar and up$/) do
  pending # express the regexp above with the code you wish you had
end
