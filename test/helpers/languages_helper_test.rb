require "test_helper"

describe LanguagesHelper do

  it 'gets the current year' do
    # edge case: the day before our system ticks over to the next year
    travel_to Time.zone.local(2025, 9, 30)
    _(get_current_year).must_equal 2025
  end

  it 'knows that the year ticks over on Oct 1' do
    # edge case: the day after our system ticks over to the next year
    travel_to Time.zone.local(2025, 10, 1)
    _(get_current_year).must_equal 2026
  end

end