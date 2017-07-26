Then(/^I can click on any zone in the map$/) do
  within('map#zone-map') do
    Zone.find_each do |zone|
      page.assert_selector("area[href='#{zone_path(zone)}']")
    end
  end
end

Then(/^I can click on only my zones in the map$/) do
  within('map#zone-map') do
    Zone.find_each do |zone|
      if @me.zones.include? zone
        page.assert_selector("area[href='#{zone_path(zone)}']")
      else
        page.refute_selector("area[href='#{zone_path(zone)}']")
      end
    end
  end
end

Then(/^all states of the zone are listed$/) do
  within('#states-tab') do
    @object.geo_states.each do |state|
      page.assert_selector('a', text: state.name)
    end
  end
end

Then(/^all languages of the zone are listed$/) do
  within('#languages-tab') do
    @object.languages.each do |lang|
      page.assert_selector('a', text: lang.name)
    end
  end
end

Then(/^only my states of the zone are listed$/) do
  within('#states-tab') do
    @object.geo_states.each do |state|
      if @me.geo_states.include? state
        page.assert_selector('a', text: state.name)
      else
        page.refute_selector('a', text: state.name)
      end
    end
  end
end

And(/^only my languages of the zone are listed$/) do
  my_languages = @object.languages.user_limited(@me)
  within('#languages-tab') do
    @object.languages.each do |lang|
      if my_languages.include? lang
        page.assert_selector('a', text: lang.name)
      else
        page.refute_selector('a', text: lang.name)
      end
    end
  end
end