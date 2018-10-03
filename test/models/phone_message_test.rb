require "test_helper"

describe PhoneMessage do
  let(:phone_message) { FactoryBot.build(:phone_message) }

  it "must be valid" do
    value(phone_message).must_be :valid?
  end

  it "scopes to pending" do
    phone_message.save!
    has_error = phone_message.dup
    has_error.error_messages = "error!"
    has_error.save!
    sent = phone_message.dup
    sent.sent_at = Time.now
    sent.save!
    pending = PhoneMessage.pending
    _(pending).must_include phone_message
    _(pending).wont_include has_error
    _(pending).wont_include sent
  end
end
