FactoryBot.define do
  factory :project_stream do
    project
    ministry
    association :supervisor, factory: :user
  end
end
