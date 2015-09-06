require 'test_helper'

describe Event do

  let(:event) { Event.new event_label: "label", event_date: Date.today }

  it "must be valid" do
    value(event).must_be :valid?
  end
  
end
