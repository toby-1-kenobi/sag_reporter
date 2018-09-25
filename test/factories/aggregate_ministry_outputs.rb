FactoryBot.define do
  factory :aggregate_ministry_output do
    association :deliverable, reporter: :facilitator
    association :creator, factory: :user
    association :state_language
    value { 1 }
    month { "2018-08" }
    actual { false }
  end
end
