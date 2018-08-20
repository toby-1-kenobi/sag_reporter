require 'test_helper'

describe Event do

  let(:event) { Event.new record_creator: FactoryBot.build(:user),
    geo_state: FactoryBot.build(:geo_state),
    participant_amount: 15,
    event_label: "label",
    event_date: Date.today,
    sub_district: SubDistrict.new(district: District.new(geo_state: FactoryBot.build(:geo_state)))
  }

  # it "must be valid" do
  #   value(event).must_be :valid?
  # end
  
end
