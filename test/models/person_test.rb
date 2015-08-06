require "test_helper"

describe Person do

  let(:person) { Person.new(name: "Fred") }

  it "is valid with only a name" do
    value(person).must_be :valid?
  end

  it "is not valid without a name" do
  	person.name = ""
  	_(person).wont_be :valid?
  end

  it "doesn't have a very long name" do
  	person.name = "a" * 51
  	_(person).wont_be :valid?
  end

  it "may have a 10-digit phone number" do
    person.phone = "1" *10
    _(person).must_be :valid?
  end

  it "cannot have a phone number with less than 10 digits" do
  	person.phone = "1" *9
  	_(person).wont_be :valid?
  end

  it "cannot have a phone number with more than 10 digits" do
  	person.phone = "1" *11
  	_(person).wont_be :valid?
  end

  it "cannot have a phone number with letters" do
  	person.phone = "098765432a"
  	_(person).wont_be :valid?
  end

  it "removes white space and hyphens from phone numbers" do
  	person.phone = " 123-45\t6 \n\t7 8-90 "
  	_(person).must_be :valid?
  	_(person.phone).must_equal "1234567890"
  end

  it "removes indian prefixes from phone numbers" do
  	person.phone = "(+91) 1234 567 890"
  	_(person).must_be :valid?
  	_(person.phone).must_equal "1234567890"
  	person.phone = "01234567890"
  	_(person).must_be :valid?
  	_(person.phone).must_equal "1234567890"
  end

  it "does not remove digits that may look like prefixes from phone numbers" do
  	person.phone = "91 1234 5678"
  	_(person).must_be :valid?
  	_(person.phone).must_equal "9112345678"
  	person.phone = "0123456789"
  	_(person).must_be :valid?
  	_(person.phone).must_equal "0123456789"
  end

end
