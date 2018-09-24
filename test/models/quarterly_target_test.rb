require "test_helper"

describe QuarterlyTarget do
  let(:quarterly_target) { FactoryBot.build(:quarterly_target) }

  it "must be valid" do
    value(quarterly_target).must_be :valid?
  end

  it "scopes by year" do
    q2018a = FactoryBot.create(:quarterly_target, quarter: '2018-2')
    q2018b = FactoryBot.create(:quarterly_target, quarter: '2018-4')
    q2019 = FactoryBot.create(:quarterly_target, quarter: '2019-3')
    result = QuarterlyTarget.year(2018)
    _(result).must_include q2018a
    _(result).must_include q2018b
    _(result).wont_include q2019
  end

  it "is unique across language, deliverable and quarter" do
    quarterly_target.save
    qt2 = quarterly_target.dup
    _(qt2).wont_be :valid?
    qt2.quarter = '2222-2'
    _(qt2).must_be :valid?
    qt2.quarter = quarterly_target.quarter
    qt2.deliverable = FactoryBot.build(:deliverable)
    _(qt2).must_be :valid?
    qt2.deliverable = quarterly_target.deliverable
    qt2.state_language = FactoryBot.build(:state_language)
    _(qt2).must_be :valid?
  end
end
