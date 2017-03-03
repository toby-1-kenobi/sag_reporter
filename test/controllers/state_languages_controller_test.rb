require "test_helper"

describe StateLanguagesController do

  def setup
    @admin_user = users(:andrew)
  end

  it 'must set the outcome_scores variable for transformation spreadsheet' do
    log_in_as(@admin_user)
    get :transformation_spreadsheet,
        year_a: 2016,
        month_a: 1,
        year_b: 2016,
        month_b: 6,
        format: :csv
    assigns(:outcome_scores).wont_be_nil
  end
end
