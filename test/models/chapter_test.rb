require "test_helper"

describe Chapter do
  let(:chapter) { FactoryBot.build(:chapter) }

  it "must be valid" do
    value(chapter).must_be :valid?
  end
end
