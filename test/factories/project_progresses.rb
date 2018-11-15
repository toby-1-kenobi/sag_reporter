FactoryBot.define do
  factory :project_progress do
    project_stream
    month { '2018-11' }
    approved false
  end
end
