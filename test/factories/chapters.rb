FactoryBot.define do
  factory :chapter do
    book
    sequence(:number){ |n| n }
    verses { 100 }
  end
end
