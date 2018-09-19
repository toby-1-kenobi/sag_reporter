FactoryBot.define do
  factory :aggregate_quarterly_target do
    state_language
    aggregate_deliverable
    quarter { "2018-3" }
    value { 20 }
  end
end
