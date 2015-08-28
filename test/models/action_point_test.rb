require "test_helper"

describe ActionPoint do

  let(:john) { Person.new name: "John" }
  let(:action_point) { ActionPoint.new responsible: john, content: "do something" }

  it "must be valid" do
    value(action_point).must_be :valid?
  end

  it "wont be valid without content" do
    action_point.content = nil
    value(action_point).wont_be :valid?
    action_point.content = ""
    value(action_point).wont_be :valid?
  end

  it "wont be valid without a responsible person" do
    action_point.responsible = nil
    value(action_point).wont_be :valid?
  end

  it "must be incomplete until marked completed" do
    value(action_point).must_be :incomplete?
    action_point.mark_completed
    value(action_point).must_be :complete?
  end

end
