FactoryBot.define do
  factory :church_team do
    name { "My Local Church" }
    association :organisation, church: true
    geo_state
    village { "My Village" }
  end
end
