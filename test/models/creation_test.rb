require "test_helper"

describe Creation do
  let(:creation) { Creation.new }

  it "must be valid" do
    value(creation).must_be :valid?
  end
end
