FactoryBot.define do
  factory :user do
    name { "Fred" }
    phone { "8768768761" }
    email { "fred@sample.com" }
    password { "password" }
    password_confirmation { "password" }
    geo_states  { |a| [a.association(:geo_state)] }
  end
end
