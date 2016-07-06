require "test_helper"

describe StateLanguagesController do

  def setup
    @user = users(:andrew)
  end

  it 'must set the outcomes_score variable for transformation spreadsheet' do
    log_in_as(@user)
    get :transformation_spreadsheet,
        year_a: 2016,
        month_a: 1,
        year_b: 2016,
        month_b: 6,
        format: :csv
    value(@outcomes_score).wont_be_nil
  end
end
