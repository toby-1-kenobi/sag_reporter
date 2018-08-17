require "test_helper"

# describe OutputCount do
#   let(:output_count) { OutputCount.new(
#     user: users(:andrew),
#     geo_state: geo_states(:nb),
#     language: languages(:toto),
#     year: 2015,
#     month: 1,
#     output_tally: output_tally
#   ) }
#   let(:output_tally) { OutputTally.new }
#
#   it "must be valid" do
#     value(output_count).must_be :valid?
#   end
#
#   it "wont be valid if the language is not in the state" do
#     output_count.geo_state = geo_states(:assam)
#     _(output_count).wont_be :valid?
#   end
# end
