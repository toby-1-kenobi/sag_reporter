
When(/^(.+) for my ([^\s]+)$/) do |other_step, object|
  step 'I am a user' unless @me
  if @me.respond_to? object
    @object = @me.send object
  elsif @me.respond_to? object.pluralize
    objects = @me.send object.pluralize
    if objects.empty?
      raise "I don't have any #{object.pluralize}"
    end
    @object = objects.first
  else
    raise "I don't understand 'for my #{object}''"
  end
  step other_step
end

When(/^(.+) for ([A-Z][a-z\s]* ?[A-Z]?[a-z]*)'s ([^\s]+)$/) do |other_step, user_name, object|
  user = User.find_by_name user_name
  if user.respond_to? object
    @object = user.send object
  elsif user.respond_to? object.pluralize
    objects = user.send object.pluralize
    if objects.empty?
      raise "#{user_name} doesn't have any #{object.pluralize}"
    end
    @object = objects.first unless objects.include? @object
  else
    raise "I don't understand \"for #{user_names}'s #{object}\""
  end
  step other_step
end

When(/^(.+) (?:on|in) (the|a) ([^\s]+)$/) do |other_step, article, element|
  selector_begin = (article == 'the') ? '#' : '.'
  within("#{selector_begin}#{element}") do
    step other_step
  end
end

Given(/^(.+?) data is loaded into the database$/) do |fixture_file|
  case fixture_file
    when "seed", "all", "all seed"
      models = ['zones', 'geo_states', 'languages', 'language_families', 'state_languages', 'topics', 'organisations', 'finish_line_markers']
      models.each do |model_name|
        step "#{model_name} data is loaded into the database"
      end
    else
      ActiveRecord::FixtureSet.create_fixtures("#{Rails.root}/db/seed_fixtures", fixture_file)
  end
end

Given(/^I am a user$/) do
  @me = User.new(
      name: 'My Name',
      phone: '7777777777',
      password: 'my password',
      password_confirmation: 'my password',
      mother_tongue: Language.take
  )
  @me.geo_states << GeoState.take
  @me.save
  _(@me).must_be :persisted?
end

Given(/^I login$/) do
  step 'I am a user' unless @me
  visit login_path
  fill_in 'Username', with: @me.phone
  fill_in 'Password', with: 'my password'
  click_on 'Log in'
  _(current_path).must_equal two_factor_auth_path
  page.find('#session_otp_code').set(@me.otp_code)
  click_on 'Log in'
  _(current_path).wont_equal two_factor_auth_path
  _(current_path).wont_equal login_path
  puts "logged in as #{@me.name} in #{@me.geo_states.pluck(:name).to_sentence}"
end

When(/^I try to go to the ([^\s]+) page$/) do |page_name|
  path_method_str = "#{page_name}_path"
  path_method_str += '(@object)' if @object
  path = eval path_method_str
  puts path
  visit path
end

Then(/^I am on the ([^\s]+) page$/) do |page_name|
  path_method_str = "#{page_name}_path"
  path_method_str += '(@object)' if @object
  path = eval path_method_str
  page.current_path.must_equal path
end

Given(/^I go to the ([^\s]+) page$/) do |page_name|
  step "I try to go to the #{page_name} page"
  step "I am on the #{page_name} page"
end

When(/^I (am|am not) an? ([^\s]+) user$/) do |am_or_not, attr|
  step 'I am a user' unless @me
  i_am = am_or_not == 'am'
  @me.update_attribute(attr, i_am)
  if i_am
    _(@me).must_be "#{attr}?".to_sym
    puts "set user \"#{@me.name}\" to be #{attr}"
  else
    _(@me).wont_be "#{attr}?".to_sym
    puts "set user \"#{@me.name}\" to not be #{attr}"
  end
end

And(/^I (see|do not see) a link to the ([^\s]+) page$/) do |see_or_not, page_name|
  path_method_str = "#{page_name}_path"
  path = eval path_method_str
  if see_or_not == 'see'
    page.assert_selector("a[href='#{path}']")
  else
    page.refute_selector("a[href='#{path}']")
  end
end

Then(/^I (see|do not see) an "([^"]*)" button$/) do |see_or_not, button_name|
  if see_or_not == 'see'
    page.assert_selector(:link_or_button, button_name)
  else
    page.refute_selector(:link_or_button, button_name)
  end
end

Then(/^show me$/) do
  save_and_open_page
end

Given(/^I am in the state for that$/) do
  step 'I am a user' unless @me
  if @object and @object.respond_to?(:geo_state)
    state = @object.send(:geo_state)
    unless @me.geo_states.include? state
      @me.geo_states << state
      puts "added #{state.name} to #{@me.name}"
    end
  elsif @object and  @object.respond_to?(:geo_states)
    @object.send(:geo_states).each do |state|
      unless @me.geo_states.include? state
        @me.geo_states << state
        puts "added #{state.name} to #{@me.name}"
      end
    end
  else
    puts 'no object' if @object.nil?
    raise 'you are in the state for what?'
  end
end

When(/^I click on "([^"]*)"$/) do |link_name|
  click_on link_name
end