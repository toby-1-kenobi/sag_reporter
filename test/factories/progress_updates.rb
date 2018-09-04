FactoryBot.define do
  factory :progress_update do
    language_progress
    user
    progress { 1 }
    month { 1 }
    year { 2018 }
  end
end
