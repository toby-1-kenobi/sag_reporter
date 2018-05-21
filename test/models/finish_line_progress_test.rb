require 'test_helper'

describe FinishLineProgress do
  let(:flp) { FinishLineProgress.new(
      status: 0,
      language: languages(:toto),
      finish_line_marker: finish_line_markers(:flm_00)
  ) }

  it "must be valid" do
    value(flp).must_be :valid?
  end

  it "wont be valid without status" do
    flp.status = nil
    value(flp).wont_be :valid?
  end

  it "wont be valid without language" do
    flp.language = nil
    value(flp).wont_be :valid?
  end

  it "wont be valid without marker" do
    flp.finish_line_marker = nil
    value(flp).wont_be :valid?
  end

  it 'gets the current year' do
    # edge case: the day before our system ticks over to the next year
    travel_to Time.zone.local(2025, 9, 30)
    _(FinishLineProgress.get_current_year).must_equal 2025
  end

  it 'knows that the year ticks over on Oct 1' do
    # edge case: the day after our system ticks over to the next year
    travel_to Time.zone.local(2025, 10, 1)
    _(FinishLineProgress.get_current_year).must_equal 2026
  end

  it "finds the current one if there's none closer earlier than specified year" do
    flp.save
    _(FinishLineProgress.closest_to(flp.language_id, flp.finish_line_marker_id, 3000)).must_equal flp
  end

  it "finds the latest one before specified year" do
    attributes = flp.attributes.except('id', 'created_at', 'updated_at', 'year')
    flp.save
    FinishLineProgress.stub :get_current_year, 2018 do
      target = FinishLineProgress.create(attributes.merge(year: 2020))
      _(FinishLineProgress.closest_to(flp.language_id, flp.finish_line_marker_id, 3000)).must_equal target
    end
  end

  it "creates from next year when it only finds current" do
    attributes = flp.attributes.except('id', 'created_at', 'updated_at', 'year')
    flp.save
    FinishLineProgress.stub :get_current_year, 2018 do
      assert_difference('FinishLineProgress.count', +2) do
        FinishLineProgress.find_or_create_by(attributes.merge(year: 2020))
      end
    end
  end

  it "creates current year and from next year when it finds none" do
    attributes = flp.attributes.except('id', 'created_at', 'updated_at', 'year')
    FinishLineProgress.stub :get_current_year, 2018 do
      assert_difference('FinishLineProgress.count', +3) do
        FinishLineProgress.find_or_create_by(attributes.merge(year: 2020))
      end
    end
  end

end
