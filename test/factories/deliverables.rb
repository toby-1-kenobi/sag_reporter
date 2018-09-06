FactoryBot.define do
  factory :deliverable do
    sequence(:number){ |n| n }
    ministry
  end
end
