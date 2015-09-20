require "test_helper"

feature "MultipleStates" do
  scenario "the test is sound" do
    visit root_path
    page.wont_have_selector("#user-geo_states-dropdown .geo_states-option", :visible)
    page.must_have_content "Hello World"
    page.wont_have_content "Goobye All!"

  end
end
