FactoryBot.define do
  factory :mt_resource do
    name { "My MT resource" }
    language
    medium { 1 }
    cc_share_alike { true }
    geo_state
  end
end
