require "test_helper"

describe Translatable do
  let(:translatable) { Translatable.new }

  it "must be valid" do
    value(translatable).must_be :valid?
  end
end
