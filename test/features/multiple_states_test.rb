require "test_helper"

feature "MultipleStates" do
  scenario "the test is sound" do
    visit root_path
    page.wont_have_selector("#user-geo_states-dropdown .geo_states-option", :visible)
    page.wont_have_content "Goobye All!"
#    puts "Hello World!"

    page.all('body script', visible: false).each do |el|
      puts 'script: '
      puts el.native.text
    end

  end
end
