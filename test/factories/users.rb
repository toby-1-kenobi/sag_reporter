FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    phone { Faker::Number.number(10) }
    email { Faker::Internet.email }
    password { "password" }
    password_confirmation { "password" }
    geo_states  { |a| [a.association(:geo_state)] }

    factory :user_with_curatings do
      transient{ curating_count { 1 } }
      after(:create) do |user, evaluator|
        create_list(:curating, evaluator.curating_count, user: user)
      end
    end
  end
end
