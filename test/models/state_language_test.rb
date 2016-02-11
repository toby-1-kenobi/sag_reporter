require "test_helper"

describe StateLanguage do
  let(:state_language) { StateLanguage.new geo_state: geo_states(:nb), language: languages(:toto) }

  it "must be valid" do
    value(state_language).must_be :valid?
  end
end
