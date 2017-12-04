require 'test_helper'

describe ReportsController do

  before do
    @admin_user = users(:andrew)
    @pleb_user = users(:peter)
    @national_user = users(:norman)
    @report = reports(:'report-1')
  end

  it 'must show a report for another user in the same state' do
    log_in_as @pleb_user
    report_state = @report.geo_state
    @pleb_user.geo_states << report_state unless @pleb_user.geo_states.include? report_state
    _(@pleb_user).wont_equal @report.reporter
    get :show, id: @report.id
    _(response).must_be :success?
  end

  it 'wont show a report from another user in another state' do
    log_in_as @pleb_user
    @report.geo_state = geo_states(:gujarat)
    @report.save!
    _(@pleb_user.geo_states).wont_include @report.geo_state
    _(@pleb_user).wont_equal @report.reporter
    get :show, id: @report.id
    assert_redirected_to root_path
  end

  it 'must show to a national user any report' do
    log_in_as @national_user
    @report.geo_state = geo_states(:gujarat)
    @report.save!
    _(@national_user.geo_states).wont_include @report.geo_state
    _(@national_user).wont_equal @report.reporter
    get :show, id: @report.id
    _(response).must_be :success?
  end

  it 'must get new' do
    log_in_as(@admin_user)
    get :new
    assert_response :success
  end

  it 'must get edit' do
    log_in_as(@admin_user)
    get :edit, id: @report
    assert_response :success
  end

  it 'must get index' do
    log_in_as(@admin_user)
    get :index
    assert_response :success
  end

end
