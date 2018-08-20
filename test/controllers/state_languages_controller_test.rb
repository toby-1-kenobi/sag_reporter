require "test_helper"

describe StateLanguagesController do

  before do
    FactoryBot.create(:language, name: 'English', locale_tag: 'en')
    admin_user = FactoryBot.create(:user, admin: true)
    log_in_as(admin_user)
  end

  it 'must set the outcome_scores variable for transformation spreadsheet' do
    get :transformation_spreadsheet,
        year_a: 2016,
        month_a: 1,
        year_b: 2016,
        month_b: 6,
        format: :csv
    assigns(:outcome_scores).wont_be_nil
  end
end
