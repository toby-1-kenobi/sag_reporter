every 1.day, :at => '12:00 pm' do
  runner "user.disable_stale_accounts"
end