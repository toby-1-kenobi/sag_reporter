FactoryBot.define do
  factory :project_supervisor do
    project
    user
    role { 0 }
  end
end
