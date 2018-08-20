FactoryBot.define do
  factory :edit do
    user
    model_klass_name { "Language" }
    record_id { 1 }
    attribute_name { "name" }
    old_value { "Old Language Name" }
    new_value { "New Language Name" }
  end
end
