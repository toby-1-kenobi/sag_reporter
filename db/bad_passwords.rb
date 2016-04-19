User.find_each do |user|
  if user.authenticate 'password'
    puts "#{user.id} #{user.name} #{user.phone}"
  else
    puts "* #{user.id} #{user.name}"
  end
end