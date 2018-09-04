FactoryBot.define do
  factory :impact_report do
    after(:build) do |ir|
      ir.report || FactoryBot.build(:report, impact_report: ir)
    end
  end
end
