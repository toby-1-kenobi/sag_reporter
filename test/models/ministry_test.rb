require 'test_helper'

describe Ministry do

  let(:ministry) { FactoryBot.build(:ministry) }

  it "must be valid" do
    value(ministry).must_be :valid?
  end

end

