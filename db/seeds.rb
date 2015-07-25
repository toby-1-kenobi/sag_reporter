# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#Permission.create(name: "create_user", description: "Create a new user")
#Permission.create(name: "edit_user", description: "Edit any user details")
#Permission.create(name: "view_all_users", description: "View all users")
#Permission.create(name: "delete_user", description: "Delete any other user")
#Permission.create(name: "view_roles", description: "View all roles with permissions")
#Permission.create(name: "edit_role", description: "Edit any role with its permissions")
#Permission.create(name: "create_role", description: "Create a new role")

#admin_role = Role.create(name: "admin")
#admin_role.permissions = Permission.all

#User.create!(name:  "admin",
#             phone: "1234567890",
#             password:              "password",
#             password_confirmation: "password",
#             role: admin_role)

#99.times do |n|
#  name  = Faker::Name.name
#  phone = Faker::Number.number(10)
#  password = "password"
#  User.create!(name:  name,
#               phone: phone,
#               password:              password,
#               password_confirmation: password)
#end