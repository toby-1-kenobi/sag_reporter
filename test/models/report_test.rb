require 'test_helper'

describe Report do

  let(:report) { Report.new(content: "report content", reporter: User.take) }

  it "is valid with content and reporter" do
  	_(report).must_be :valid?
  end

  it "is not valid without content" do
  	report.content = ""
  	_(report).wont_be :valid?
  end

  it "is not valid without reporter" do
  	report.reporter = nil
  	_(report).wont_be :valid?
  end

  it "may have many languages" do
  	report.languages << Language.take(2)
  	_(report.languages.length).must_equal 2
  end

  it "may have many topics" do
  	report.topics << Topic.take(2)
  	_(report.topics.length).must_equal 2
  end

  it "may have content in various scripts" do
  	report.content = "বাংলা"
  	report.save
  	found = Report.find_by_content("বাংলা")
  	_(found).must_equal report
  end

end
