require 'test_helper'

describe ChurchTeam do
  let(:church_team) { FactoryBot.build(:church_team) }

  it "must be valid" do
    value(church_team).must_be :valid?
  end
end
