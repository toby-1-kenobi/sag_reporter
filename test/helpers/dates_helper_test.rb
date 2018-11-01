require "test_helper"

describe DatesHelper do

  it "must know the current quarter" do
    travel_to Time.zone.local(2018, Rails.configuration.year_cutoff_month, 10)
    _(current_quarter).must_equal 1
    travel 2.months
    _(current_quarter).must_equal 1
    travel 1.month
    _(current_quarter).must_equal 2
    travel 2.months
    _(current_quarter).must_equal 2
    travel 1.month
    _(current_quarter).must_equal 3
    travel 2.months
    _(current_quarter).must_equal 3
    travel 1.month
    _(current_quarter).must_equal 4
    travel 2.months
    _(current_quarter).must_equal 4
  end

  it "must know what months are in any given quarter" do
    Rails.configuration.year_cutoff_month = 5
    _(months_in_quarter 2).must_equal [8, 9, 10]
    _(months_in_quarter 4).must_equal [2, 3, 4]
    Rails.configuration.year_cutoff_month = 10
    _(months_in_quarter 1).must_equal [10, 11, 12]
    _(months_in_quarter 3).must_equal [4, 5, 6]
    Rails.configuration.year_cutoff_month = 12
    _(months_in_quarter 1).must_equal [12, 1, 2]
  end

end
