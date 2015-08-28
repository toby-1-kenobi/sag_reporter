require "test_helper"

describe Creation do

  let(:john) { Person.new name: "John" }
  let(:resource) { MtResource.new }
  let(:creation) { Creation.new person: john, mt_resource: resource }

  it "must be valid" do
    value(creation).must_be :valid?
  end

  it "wont be valid without a person" do
    creation.person = nil
    value(creation).wont_be :valid?
  end

  it "wont be value without a resource" do
    creation.mt_resource = nil
    value(creation).wont_be :valid?
  end
  

end
