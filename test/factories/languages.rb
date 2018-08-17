FactoryBot.define do
  factory :language do
    name { "My Language" }
    iso { "abc" }
    geo_states { |a| [a.association(:geo_state)] }
  end
end
