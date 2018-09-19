FactoryBot.define do
  factory :organisation do
    sequence(:name){ |n| "My Org Name #{n}" }
  end
end
