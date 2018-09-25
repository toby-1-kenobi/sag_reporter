FactoryBot.define do
  factory :ministry do
    sequence(:code){ |n| n.to_s.rjust(2, '0') }
    topic
  end
end
