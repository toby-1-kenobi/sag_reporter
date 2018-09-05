FactoryBot.define do
  factory :language_progress do
    state_language
    progress_marker

    factory :language_progress_with_updates do
      transient{ update_count { 5 } }
      after(:create) do |lp, evaluator|
        create_list(:progress_update, evaluator.update_count, language_progress: lp)
      end
    end
  end
end
