Given(/^I have contacts$/) do
  fred = Person.create(name: "Fred", record_creator: @me)
  _(fred.record_creator.role.name).must_equal "admin"
  wilma = Person.create(name: "Wilma", record_creator: @me)
end

Given(/^there are people who are not my contacts$/) do
  barney = Person.create(name: "Barney")
  _(barney.record_creator).must_be_nil
  Person.create(name: "Betty")
end

When(/^I follow the link to my contacts$/) do
  click_on "view-contacts-link"
end

Then(/^I see the names of only my contacts$/) do
  _(page.has_content? "My contacts").must_equal true
  _(page.has_content? "Fred").must_equal true
  _(page.has_content? "Wilma").must_equal true
  _(page.has_content? "Barney").must_equal false
  _(page.has_content? "Betty").must_equal false
end

When(/^I click on show all people$/) do
  click_on "Show all people"
end

Then(/^I see the names of more people$/) do
  _(page.has_content? "All people").must_equal true
  _(page.has_content? "Barney").must_equal true
  _(page.has_content? "Betty").must_equal true
end
