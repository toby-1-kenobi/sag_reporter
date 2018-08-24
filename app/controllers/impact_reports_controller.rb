require 'csv'

class ImpactReportsController < ApplicationController

  before_action :require_login

  # Let only permitted users do some things
  before_action only: [:edit, :update] do
    redirect_to root_path unless logged_in_user.admin? or logged_in_user?(Report.find(params[:id]).reporter)
  end

  before_action only: [:show] do
    redirect_to root_path unless logged_in_user?(ImpactReport.find(params[:id]).reporter) or logged_in_user.national?
  end

  before_action only: [:index, :spreadsheet] do
    redirect_to root_path unless logged_in_user.national?
  end

  before_action only: [:archive, :unarchive] do
    redirect_to root_path unless logged_in_user.admin?
  end

  before_action only: [:tag] do
    redirect_to root_path unless logged_in_user.trusted? or logged_in_user.reports.active.any?
  end

  def show
  	@report = ImpactReport.find(params[:id])
  end

  def edit
    @report = ImpactReport.find(params[:id])
    @geo_states = @report.available_geo_states(logged_in_user)
    @minority_languages = Language.minorities(@geo_states).order("LOWER(languages.name)")
    @topics = Topic.all
  end

  def update
    @report = ImpactReport.find(params[:id])
    if @report.update_attributes(impact_report_params)
      if params['impact_report']['languages']
        @report.languages.clear
        params['impact_report']['languages'].each do |lang_id, value|
          @report.languages << Language.find_by_id(lang_id.to_i)
        end
      end
      flash["success"] = "Report updated"
      redirect_to @report
    else
      @minority_languages = Language.minorities(logged_in_user.geo_states).order("LOWER(languages.name)")
      @topics = Topic.all
      render 'edit'
    end
  end

  def archive
    report = ImpactReport.find(params[:id])
    report.archived!
    redirect_back_or root_path
  end

  def unarchive
    report = ImpactReport.find(params[:id])
    report.active!
    redirect_back_or report
  end

  def tag
    @impact_report_id = params[:id]
    respond_to :js
  end

  def tag_update
  	@impact_report = ImpactReport.find(params[:id])
    @pm = ProgressMarker.find(params[:pm_id])
    if params["pm-#{@pm.id}"].present?
      @impact_report.progress_markers << @pm unless @impact_report.progress_markers.include?(@pm)
    else
      @impact_report.progress_markers.delete(@pm)
    end
    respond_to :js
  end

  def shareable
    @report = ImpactReport.find(params[:id])
    @report.update_attribute(:shareable, params[:shareable].present?)
    respond_to :js
  end

    private

    def impact_report_params
      safe_params = [
        :content,
        :geo_state_id,
        :report_date,
        :state
      ]
      safe_params.reject! :state unless logged_in_user.admin?
      if params[:impact_report][:report_date]
        params[:impact_report][:report_date] = DateParser.parse_to_db_str(params[:impact_report][:report_date])
      end
      permitted = params.require(:impact_report).permit(safe_params)
    end

end
