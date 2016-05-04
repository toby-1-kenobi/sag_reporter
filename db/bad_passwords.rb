# list the users that have not changed from the default password
# also list the users that have changed their password with an asterisk
default_password = 'password'
count = 0
User.find_each do |user|
  if user.authenticate default_password
    puts "#{user.id} #{user.name} #{user.phone}"
    count += 1
  else
    puts "* #{user.id} #{user.name}"
  end
end
puts "#{count} of #{User.count} users still have the default password"