require "test_helper"

describe ImpactReportsController do

  it 'lets high sensitivity users see reports of others when tagging' do
    log_in_as users(:andrew)
    get :tag
    _(response).must_be :success?
    _(assigns(:reports).pluck :id).must_include impact_reports(:'impact-report-norman').id
  end

  it 'doesnt let low sensitivity users see reports of others when tagging' do
    log_in_as users(:norman)
    get :tag
    _(response).must_be :success?
    _(assigns(:reports).pluck :id).wont_include impact_reports(:'impact-report-andrew').id
  end

end
