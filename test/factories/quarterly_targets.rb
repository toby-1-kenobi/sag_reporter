FactoryBot.define do
  factory :quarterly_target do
    state_language
    deliverable
    quarter { "2018-2" }
    value { 1 }
  end
end
