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
  	@minority_languages = Language.where(lwc: false)
  	@topics = Topic.all
  end

  def create
  	full_params = report_params.merge({reporter: current_user})
  	@report = Report.new(full_params)
    if @report.save
      if params['report']['languages']
        params['report']['languages'].each do |lang_id, value|
          @report.languages << Language.find_by_id(lang_id.to_i)
        end
      end
      if params['report']['topics']
        params['report']['topics'].each do |top_id, value|
          @report.topics << Topic.find_by_id(top_id.to_i)
        end
      end
      flash["success"] = "New Report Submitted!"
      redirect_to @report
    else
  	  @minority_languages = Language.where(lwc: false)
  	  @topics = Topic.all
      render 'new'
    end
  end

  def show
  	@report = Report.find(params[:id])
  end

  def edit
  	@report = Report.find(params[:id])
  	@minority_languages = Language.where(lwc: false)
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
      redirect_back_or @report
    end
  end

  def index
  	@reports = Report.all
  	store_location
  end

  def by_language
  	@reports = Report.all
  	@languages = Language.all
  	store_location
  end

  def by_topic
  	@reports = Report.all
  	@topics = Topic.all
  	store_location
  end

  def by_reporter
  	@reports = Report.all
  	store_location
  end

  def archive
  end

  def unarchive
  end

    private

    def report_params
      permitted = params.require(:report).permit(:report_type, :content)
    end

end
