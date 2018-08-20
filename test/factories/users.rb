FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    phone { Faker::Number.number(10) }
    email { Faker::Internet.email }
    password { "password" }
    password_confirmation { "password" }
    geo_states  { |a| [a.association(:geo_state)] }
  end
end
