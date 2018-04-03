require "test_helper"

describe Dialect do

  let(:dialect) { Dialect.new name: 'test' }

  it "must be valid" do
    value(dialect).must_be :valid?
  end

  it "wont be valid wthout a name" do
    dialect.name = ''
    value(dialect).wont_be :valid?
  end

end
