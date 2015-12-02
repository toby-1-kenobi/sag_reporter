class ReportsController < ApplicationController

  helper ColoursHelper

  before_action :require_login

    # Let only permitted users do some things
  before_action only: [:new, :create] do
    redirect_to root_path unless current_user.can_create_report?
  end

  before_action only: [:index, :by_language, :by_topic, :by_reporter] do
    redirect_to root_path unless current_user.can_view_all_reports?
  end

  before_action only: [:show] do
  	# show shows single report only to reporter when report first created
  	redirect_to root_path unless current_user?(Report.find(params[:id]).reporter) or current_user.can_view_all_reports?
  end

  before_action only: [:edit, :update] do
    redirect_to root_path unless current_user.can_edit_report? or current_user?(Report.find(params[:id]).reporter)
  end

  before_action only: [:archive, :unarchive] do
    redirect_to root_path unless current_user.can_archive_report?
  end

  def new
  	@report = Report.new
  	@minority_languages = Language.minorities(current_user.geo_states).order("LOWER(languages.name)")
  	@topics = Topic.all
  end

  def create
  	full_params = report_params.merge({reporter: current_user})
    if params["report-type"] == "planning" 
  	  @report = Report.new(full_params)
    else
      @report = ImpactReport.new(full_params)
    end
    if @report.save
      if params['report']['languages']
        params['report']['languages'].each do |lang_id, value|
          @report.languages << Language.find_by_id(lang_id.to_i)
        end
      end
      if params['report']['topics'] and params["report-type"] == "planning"
        params['report']['topics'].each do |top_id, value|
          @report.topics << Topic.find_by_id(top_id.to_i)
        end
      end
      flash["success"] = "New Report Submitted!"
      redirect_to @report
    else
      @minority_languages = Language.minorities(current_user.geo_states).order("LOWER(languages.name)")
  	  @topics = Topic.all
      render 'new'
    end
  end

  def show
    @report = Report.find(params[:id])
  end

  def edit
    @report = Report.find(params[:id])
    @geo_states = @report.available_geo_states(current_user)
    @minority_languages = Language.minorities(@geo_states)
    @topics = Topic.all
  end

  def update
  	@report = Report.find(params[:id])
  	if @report.update_attributes(report_params)
      if params['report']['languages']
        @report.languages.clear
        params['report']['languages'].each do |lang_id, value|
          @report.languages << Language.find_by_id(lang_id.to_i)
        end
      end
      if params['report']['topics']
        @report.topics.clear
        params['report']['topics'].each do |top_id, value|
          @report.topics << Topic.find_by_id(top_id.to_i)
        end
      end
      flash["success"] = "Report Updated!"
      redirect_recent_or @report
    end
  end

  def index
    @reports = Report.where(geo_state: current_user.geo_state).order(:created_at => :desc).paginate(page: params[:page])
    @impact_reports = ImpactReport.where(geo_state: current_user.geo_state).order(:created_at => :desc).paginate(page: params[:page])
    recent_view
  end

  def by_language
    @reports = Report.where(geo_state: current_user.geo_state).order(:created_at => :desc)
    @impact_reports = ImpactReport.where(geo_state: current_user.geo_state).order(:created_at => :desc)
    @languages = Language.all.order("LOWER(languages.name)")
    recent_view
  end

  def by_topic
    @reports = Report.where(geo_state: current_user.geo_state).all.order(:created_at => :desc)
    @impact_reports = ImpactReport.where(geo_state: current_user.geo_state).order(:created_at => :desc)
    @topics = Topic.all
    recent_view
  end

  def by_reporter
    @reports = Report.where(geo_state: current_user.geo_state).all.order(:created_at => :desc)
    @impact_reports = ImpactReport.where(geo_state: current_user.geo_state).order(:created_at => :desc)
    recent_view
  end

  def archive
    report = Report.find(params[:id])
    report.archived!
    redirect_recent_or root_path
  end

  def unarchive
    report = Report.find(params[:id])
    report.active!
    redirect_recent_or report
  end

    private

    def report_params
      safe_params = [
        :content,
        :mt_society,
        :mt_church,
        :needs_society,
        :needs_church,
        :geo_state_id,
        :report_date,
        :state
      ]
      safe_params.reject! :state unless current_user.can_archive_report?
      if params[:report][:report_date]
        params[:report][:report_date] = DateParser.parse_to_db_str(params[:report][:report_date])
      end
      permitted = params.require(:report).permit(safe_params)
    end
  
    # Redirects to recent view (or to the default).
    def redirect_recent_or(default)
      redirect_to(session[:report_recent_view] || default)
      session.delete(:report_recent_view)
    end

    # Store which is the recent view in the session
    def recent_view
      session[:report_recent_view] = request.url if request.get?
    end

end
