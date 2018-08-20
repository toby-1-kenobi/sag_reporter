FactoryBot.define do
  factory :ministry_output do
    ministry_marker
    church_congregation
    value { 1 }
    year { 2018 }
    month { 8 }
    actual { false }
  end
end
