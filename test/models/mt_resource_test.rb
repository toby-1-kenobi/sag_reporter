require "test_helper"

describe MtResource do

  let(:mt_resource) { FactoryBot.build(:mt_resource) }

  it "must be valid" do
    mt_resource.valid?
    Rails.logger.debug(mt_resource.errors.full_messages)
    value(mt_resource).must_be :valid?
  end

  it "must update timestamp when category is added" do
    mt_resource.save
    init_value = mt_resource.updated_at
    mt_resource.product_categories << FactoryBot.create(:product_category)
    mt_resource.reload
    _(mt_resource.updated_at).must_be :>, init_value
  end

  it "must update timestamp when category is removed" do
    mt_resource.save
    cat = FactoryBot.create(:product_category)
    mt_resource.product_categories << cat
    mt_resource.reload
    init_value = mt_resource.updated_at
    mt_resource.product_categories.destroy cat
    mt_resource.reload
    _(mt_resource.updated_at).must_be :>, init_value
  end

end
