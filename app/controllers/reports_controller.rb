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
  	redirect_to root_path unless current_user?(Report.find(params[:id]).reporter)
  end

  before_action only: [:edit, :update] do
    redirect_to root_path unless current_user.can_edit_report? or current_user?(Report.find(params[:id]).reporter)
  end

  before_action only: [:archive, :unarchive] do
    redirect_to root_path unless current_user.can_archive_report?
  end

  def new
  	@report = Report.new
  	@minority_languages = Language.minorities(current_user.geo_state)
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
  	  @minority_languages = Language.minorities(current_user.geo_state)
  	  @topics = Topic.all
      render 'new'
    end
  end

  def show
  	@report = Report.find(params[:id])
  end

  def edit
  	@report = Report.find(params[:id])
  	@minority_languages = Language.minorities(current_user.geo_state)
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
  	@reports = Report.order(:created_at => :desc).paginate(page: params[:page])
    @impact_reports = ImpactReport.order(:created_at => :desc).paginate(page: params[:page])
  	recent_view
  end

  def by_language
  	@reports = Report.order(:created_at => :desc)
    @impact_reports = ImpactReport.order(:created_at => :desc)
  	@languages = Language.all
  	recent_view
  end

  def by_topic
  	@reports = Report.all.order(:created_at => :desc)
    @impact_reports = ImpactReport.order(:created_at => :desc)
  	@topics = Topic.all
  	recent_view
  end

  def by_reporter
  	@reports = Report.all.order(:created_at => :desc)
    @impact_reports = ImpactReport.order(:created_at => :desc)
  	recent_view
  end

  def archive
  	@report = Report.find(params[:id]).archived!
  	redirect_back_or @report
  end

  def unarchive
  	@report = Report.find(params[:id]).active!
  	redirect_back_or @report
  end

    private

    def report_params
      if current_user.can_archive_report?
        permitted = params.require(:report).permit(:content, :mt_society, :mt_church, :needs_society, :needs_church, :state)
      else
    	  permitted = params.require(:report).permit(:content, :mt_society, :mt_church, :needs_society, :needs_church,)
      end
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
