FactoryBot.define do
  factory :report do
    association :reporter, factory: :user
    content { "My report content" }
    geo_state
    report_date { "2018-08-17" }
    impact_report { FactoryBot.build(:impact_report) }
  end
end
