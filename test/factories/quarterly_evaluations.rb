FactoryBot.define do
  factory :quarterly_evaluation do
    project
    state_language
    ministry
    quarter { "2018-4" }
  end
end
