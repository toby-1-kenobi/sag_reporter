FactoryBot.define do
  factory :supervisor_feedback do
    ministry
    association :supervisor, factory: :user
    association :facilitator, factory: :user
    month { '2018-05' }
  end
end
