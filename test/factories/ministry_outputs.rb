FactoryBot.define do
  factory :ministry_output do
    ministry_marker
    value { 1 }
    year { 2018 }
    month { 8 }
    actual { false }
    after(:build) do |mo|
      mo.church_ministry = FactoryBot.build(:church_ministry, ministry: mo.ministry_marker.ministry)
    end
  end
end
