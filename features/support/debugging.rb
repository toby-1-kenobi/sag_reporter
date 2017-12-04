After do |scenario|
  if scenario.failed? and (ENV["debug"] == "open")
    save_and_open_page
  end
end