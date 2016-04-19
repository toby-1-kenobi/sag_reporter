User.find_each do |user|
  if user.authenticate 'password'
    puts "#{user.id} #{user.name} #{user.phone}"
  end
end