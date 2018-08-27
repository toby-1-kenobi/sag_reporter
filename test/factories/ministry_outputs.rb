FactoryBot.define do
  factory :ministry_output do
    ministry_marker
    association :creator, factory: :user
    value { 1 }
    month { "2018-08" }
    actual { false }
    after(:build) do |mo|
      mo.church_ministry = FactoryBot.build(:church_ministry, ministry: mo.ministry_marker.ministry)
    end
  end
end
