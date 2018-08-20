FactoryBot.define do
  factory :population do
    language
    amount { 1800 }
    source { "My pop source" }
    year { 2018 }
    international { false }
  end
end
