FactoryBot.define do
  factory :aggregate_ministry_output do
    aggregate_deliverable
    association :creator, factory: :user
    value { 1 }
    month { "2018-08" }
    actual { false }
    after(:build) do |mo|
      mo.language_stream = FactoryBot.build(:language_stream, ministry: mo.aggregate_deliverable.ministry)
    end
  end
end
