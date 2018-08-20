FactoryBot.define do
  factory :church_congregation do
    name { "My Local Church" }
    association :organisation, church: true
    village { "My Village" }
  end
end
