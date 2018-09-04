FactoryBot.define do
  factory :facilitator_feedback do
    church_ministry
    month { "2018-08" }
    feedback { "My feedback" }
  end
end
