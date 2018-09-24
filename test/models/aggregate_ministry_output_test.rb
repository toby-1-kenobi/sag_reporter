require "test_helper"

describe AggregateMinistryOutput do

  let(:aggregate_ministry_output) { FactoryBot.build(:aggregate_ministry_output) }

  it "must be valid" do
    value(aggregate_ministry_output).must_be :valid?
  end

  it "wont be valid with the wrong kind of deliverable" do
    aggregate_ministry_output.deliverable.church_team!
    value(aggregate_ministry_output).wont_be :valid?
  end

end
