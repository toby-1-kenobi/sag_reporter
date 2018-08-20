FactoryBot.define do
  factory :language do
    name { "My Language #{rand 1000}" }
    iso { (0...3).map { ('a'..'z').to_a[rand(26)] }.join } # random 3 characters
    geo_states { |a| [a.association(:geo_state)] }
  end
end
