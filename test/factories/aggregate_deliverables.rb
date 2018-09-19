FactoryBot.define do
  factory :aggregate_deliverable do
    sequence(:number){ |n| n }
    ministry
  end
end
