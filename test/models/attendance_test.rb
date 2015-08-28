require "test_helper"

describe Attendance do

  let (:john) { Person.new name: "John" }
  let (:my_event) { Event.new event_label: "label", event_date: Date.today }
  let(:attendance) { Attendance.new person: john, event: my_event}

  it "must be valid" do
    value(attendance).must_be :valid?
  end

  it "wont be valid without a person" do
    attendance.person = nil
    value(attendance).wont_be :valid?
  end

  it "wont be valid without an event" do
    attendance.event = nil
    value(attendance).wont_be :valid?
  end

  it "must be unique" do
    attendance2 = attendance.dup
    attendance.save
    attendance2.wont_be :valid?
  end

end
