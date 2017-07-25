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