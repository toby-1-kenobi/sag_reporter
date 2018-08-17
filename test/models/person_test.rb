require "test_helper"

describe Person do

  let(:person) { Person.new(name: "Fred", geo_state: FactoryBot.build(:geo_state)) }

  it "is valid with only a name and geo_State" do
    value(person).must_be :valid?
  end

  it "is not valid without a name" do
  	person.name = ""
    person.valid?
  	_(person.errors[:name]).must_be :any?
  end

  it "is not valid without a geo_state" do
    person.geo_state = nil
    person.valid?
    _(person.errors[:geo_state]).must_be :any?
  end

  it "doesn't have a very long name" do
  	person.name = "a" * 51
    person.valid?
  	_(person.errors[:name]).must_be :any?
  end

  it "may have a 10-digit phone number" do
    person.phone = "1" *10
    _(person).must_be :valid?
  end

  it "cannot have a phone number with less than 10 digits" do
  	person.phone = "1" *9
    person.valid?
  	_(person.errors[:phone]).must_be :any?
  end

  it "cannot have a phone number with more than 10 digits" do
  	person.phone = "1" *11
    person.valid?
  	_(person.errors[:phone]).must_be :any?
  end

  it "cannot have a phone number with letters" do
  	person.phone = "098765432a"
    person.valid?
  	_(person.errors[:phone]).must_be :any?
  end

  it "removes white space and hyphens from phone numbers" do
  	person.phone = " 123-45\t6 \n\t7 8-90 "
    person.valid?
  	_(person.phone).must_equal "1234567890"
  end

  it "removes indian prefixes from phone numbers" do
  	person.phone = "(+91) 1234 567 890"
    person.valid?
  	_(person.phone).must_equal "1234567890"
  	person.phone = "01234567890"
    person.valid?
  	_(person.phone).must_equal "1234567890"
  end

  it "does not remove digits that may look like prefixes from phone numbers" do
  	person.phone = "91 1234 5678"
    person.valid?
  	_(person.phone).must_equal "9112345678"
  	person.phone = "0123456789"
    person.valid?
  	_(person.phone).must_equal "0123456789"
  end

end
