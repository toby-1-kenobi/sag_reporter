require "test_helper"

describe ImpactReportsController do

  let (:trusted_user) { FactoryBot.create(:user, trusted: true) }
  let (:untrusted_user) { FactoryBot.create(:user, trusted: false) }
  let (:impact_report) { FactoryBot.create(:impact_report) }

  before do
    FactoryBot.create(:language, name: 'English', locale_tag: 'en')
  end

  it 'lets high sensitivity users see reports of others when tagging' do
    log_in_as trusted_user
    get :tag
    _(response).must_be :success?
    _(assigns(:reports).pluck :id).must_include impact_report.id
  end

  it 'doesnt let low sensitivity users see reports of others when tagging' do
    log_in_as untrusted_user
    get :tag
    _(response).must_be :success?
    _(assigns(:reports).pluck :id).wont_include impact_report.id
  end

end
