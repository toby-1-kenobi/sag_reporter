
Given(/^(.*) data is loaded into the database$/) do |fixture_file|
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
  _(current_path).must_equal root_path
end

When(/^I try to go to the (.*) page$/) do |page_name|
  path = eval "#{page_name}_path"
  visit path
end

Then(/^I am on the (.*) page$/) do |page_name|
  path = eval "#{page_name}_path"
  page.current_path.must_equal path
end

Given(/^I go to the (.*) page$/) do |page_name|
  step "I try to go to the #{page_name} page"
  step "I am on the #{page_name} page"
end

When(/^I (am|am not) an? (.*) user$/) do |am_or_not, attr|
  step 'I am a user' unless @me
  i_am = am_or_not == 'am'
  @me.update_attribute(attr, i_am)
  if i_am
    _(@me).must_be "#{attr}?".to_sym
  else
    _(@me).wont_be "#{attr}?".to_sym
  end
end