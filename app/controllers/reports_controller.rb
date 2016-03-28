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

  before_action :get_translations, only: [:new, :edit]

  def new
  	@report = Report.new
    @report.pictures.build
  	@project_languages = StateLanguage.in_project.includes(:language, :geo_state).where(geo_state: current_user.geo_states)
    @topics = Topic.all
  end

  def create
    full_params = report_params.merge({reporter: current_user})
    report_factory = Report::Factory.new
    if report_factory.create_report(full_params)
      flash["success"] = "Report Submitted!"
      redirect_to report_factory.instance()
    else
      @report = report_factory.instance()
      if report_factory.error
        @report.errors.add(:base, report_factory.error.message)
      end
      if @report.errors.empty?
        flash["error"] = "Unable to submit report!"
      end
      @project_languages = StateLanguage.in_project.includes(:language, :geo_state).where(geo_state: current_user.geo_states)
      @topics = Topic.all
      get_translations
      render 'new'
    end
  end

  def show
    @report = Report.find(params[:id])
  end

  def edit
    @report = Report.find(params[:id])
    @report.pictures.build
    @geo_states = @report.available_geo_states(current_user)
    @project_languages = StateLanguage.in_project.includes(:language, :geo_state).where(geo_state: current_user.geo_states)
    @topics = Topic.all
  end

  def update
  	@report = Report.find(params[:id])
    updater = Report::Updater.new(@report)
  	if updater.update_report(report_params)
      flash["success"] = "Report Updated!"
      redirect_to @report
    else
      if updater.error
        flash['error'] = "Report update failed: #{updater.error.message}"
      end
      @geo_states = @report.available_geo_states(current_user)
      @project_languages = StateLanguage.in_project.includes(:language, :geo_state).where(geo_state: current_user.geo_states)
      @topics = Topic.all
      get_translations
      render 'edit'
    end
  end

  def index
    @geo_states = current_user.geo_states
    @reports = Report.where(geo_state: @geo_states).order(:report_date => :desc).paginate(page: params[:page])
    @impact_reports = ImpactReport.includes(:report).where(reports: {geo_state_id: @geo_states}).order(:created_at => :desc).paginate(page: params[:page])
    recent_view
  end

  def by_language
    @geo_states = current_user.geo_states
    @reports = Report.where(geo_state: @geo_states).order(:report_date => :desc)
    @impact_reports = ImpactReport.where(geo_state: @geo_states).order(:report_date => :desc)
    @languages = Language.all.order("LOWER(languages.name)")
    recent_view
  end

  def by_topic
    @geo_states = current_user.geo_states
    @reports = Report.where(geo_state: @geo_states).order(:report_date => :desc)
    @impact_reports = ImpactReport.where(geo_state: @geo_states).order(:report_date => :desc)
    @topics = Topic.all
    recent_view
  end

  def by_reporter
    @geo_states = current_user.geo_states
    @reports = Report.where(geo_state: @geo_states).order(:report_date => :desc)
    @impact_reports = ImpactReport.where(geo_state: @geo_states).order(:report_date => :desc)
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
    # make hash options into arrays
    if params["report"]["languages"]
      params["report"]["languages"] = params["report"]["languages"].keys
    else
      params["report"]["languages"] = []
    end
    if params["report"]["topics"]
      params["report"]["topics"] = params["report"]["topics"].keys
    else
      params["report"]["topics"] = []
    end
    safe_params = [
      :content,
      :mt_society,
      :mt_church,
      :needs_society,
      :needs_church,
      :geo_state_id,
      :report_date,
      :planning_report,
      :impact_report,
      :challenge_report,
      {:languages => []},
      {:topics => []},
      {:pictures_attributes => [:ref, :_destroy, :id]},
      :status
    ]
    safe_params.delete :status unless current_user.can_archive_report?
    # if we have a date try to change it to db-friendly format
    # otherwise set it to nil
    if params[:report][:report_date]
      begin
        params[:report][:report_date] = DateParser.parse_to_db_str(params[:report][:report_date]) unless params[:report][:report_date].empty?
      rescue ArgumentError
        params[:report][:report_date] = nil
      end
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

  def get_translations
    @translations = Hash.new
    if current_user.interface_language
      lang_id = current_user.interface_language.id
      Translatable.includes(:translations).find_each do |translatable|
        translation = translatable.translations.select{ |t| t.language_id == lang_id }.first
        content = (translation and translation.content) ? translation.content : translatable.content
        @translations[translatable.identifier] = content
      end
    else
      Translatable.find_each do |translatable|
        @translations[translatable.identifier] = translatable.content
      end
    end
  end

end
