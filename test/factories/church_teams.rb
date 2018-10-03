FactoryBot.define do
  factory :church_team do
    name { "My Local Church" }
    association :organisation, church: true
    state_language
    leader { "My Leader" }
  end
end
