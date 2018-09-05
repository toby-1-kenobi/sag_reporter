FactoryBot.define do
  factory :registration_approval do
    association :registering_user, factory: :user
    association :approver, factory: :user
  end
end
