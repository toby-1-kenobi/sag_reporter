FactoryBot.define do
  factory :ministry do
    sequence(:number){ |n| n }
    topic
  end
end
