require 'test_helper'

describe DateParser do

  it "must parse a date" do
    _(DateParser.parse_to_db_str('11 February, 2018')).must_equal '2018-02-11'
  end

end