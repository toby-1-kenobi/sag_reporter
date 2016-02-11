require "test_helper"

describe StateLanguage do
  let(:state_language) { StateLanguage.new }

  it "must be valid" do
    value(state_language).must_be :valid?
  end
end
