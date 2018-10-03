FactoryBot.define do
  factory :phone_message do
    user
    content { "My SMS content" }
  end
end
