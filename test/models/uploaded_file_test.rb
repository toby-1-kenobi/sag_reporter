require "test_helper"

describe UploadedFile do
  let(:uploaded_file) { UploadedFile.new }

  it "must be valid" do
    value(uploaded_file).must_be :valid?
  end
end
