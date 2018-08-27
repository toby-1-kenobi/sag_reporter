require "test_helper"

describe ProductCategory do

  let(:product_category) { FactoryBot.build(:product_category) }

  it "must be valid" do
    value(product_category).must_be :valid?
  end

  it "wont be valid with non-unique name" do
    product_category.save
    value(product_category.dup).wont_be :valid?
  end

end
