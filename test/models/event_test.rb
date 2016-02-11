require 'test_helper'

describe Event do

  let(:event) { Event.new  record_creator: users(:andrew),
    geo_state: geo_states(:nb),
    participant_amount: 15,
    event_label: "label",
    event_date: Date.today
  }

  it "must be valid" do
    value(event).must_be :valid?
  end
  
end
