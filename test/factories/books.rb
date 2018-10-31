FactoryBot.define do
  factory :book do
    name { "My book" }
    abbreviation { "mbk" }
    sequence(:number){ |n| n }
    nt { true }
  end
end
