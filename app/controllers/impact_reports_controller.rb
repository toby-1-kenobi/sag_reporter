require 'csv'

class ImpactReportsController < ApplicationController

  before_action :require_login

  # Let only permitted users do some things
  before_action only: [:new, :create] do
    redirect_to root_path unless current_user.can_create_report?
  end

  before_action only: [:edit, :update] do
    redirect_to root_path unless current_user.can_edit_report? or current_user?(Report.find(params[:id]).reporter)
  end

  before_action only: [:show] do
    redirect_to root_path unless current_user?(Report.find(params[:id]).reporter) or current_user.can_view_all_reports?
  end

  before_action only: [:index, :spreadsheet] do
    redirect_to root_path unless current_user.can_view_all_reports?
  end

  before_action only: [:archive, :unarchive] do
    redirect_to root_path unless current_user.can_archive_report?
  end

  before_action only: [:tag, :tag_update] do
    redirect_to root_path unless current_user.can_tag_report?
  end

  def index
    store_location
    @geo_states = current_user.geo_states
    @zones = Zone.of_states(@geo_states)
    @languages = Language.minorities(@geo_states).order("LOWER(languages.name)")
    @reports = ImpactReport.where(geo_state: @geo_states).order(:created_at)
  end

  def spreadsheet
    # The user can't see reports from geo_states they're not in
    # so take the intersection of the list of geo_states in the params
    # and the users geo_states
    geo_states = params['controls']['geo_state'].values.map{ |id| id.to_i } & current_user.geo_states.pluck(:id)
    languages = params['controls']['language'].values.map{ |id| id.to_i }
    @reports = ImpactReport.includes(:languages).where(geo_state: geo_states, 'languages.id' => languages)
    
    if !params["show_archived"]
      @reports = @reports.active
    end

    start_date = params['from_date'].to_date
    end_date = params['to_date'].to_date
    @reports = @reports.select do |report|
      report.report_date >= start_date and report.report_date <= end_date
    end

    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"impact-reports.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def show
  	@report = ImpactReport.find(params[:id])
  end

  def edit
    @report = ImpactReport.find(params[:id])
    @geo_states = @report.available_geo_states(current_user)
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
      @minority_languages = Language.minorities(current_user.geo_states).order("LOWER(languages.name)")
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
    store_location
    if params[:month]
      # If the month is later than current month, it must be refering to last year
      # Future dates dont make sense here
      if params[:month].to_i > Time.now.month
        @date = Time.new(Time.now.year - 1, params[:month])
      else
        @date = Time.new(Time.now.year, params[:month])
      end
    else
      # Without a month parameter we use the current month
      @date = Time.now
    end
    @date = @date.at_beginning_of_month.to_date
  	@reports = ImpactReport.active.select{ |ir| current_user.geo_states.include? ir.geo_state and ir.report_date.at_beginning_of_month.to_date == @date }
  	@outcome_areas = Topic.all
  	@progress_markers_by_oa = ProgressMarker.all.group_by{ |pm| pm.topic }
    @languages = Language.minorities(current_user.geo_states).order("LOWER(languages.name)")
    @ajax_url = url_for controller: 'impact_reports', action: 'tag_update', id: 'report_id'
  end

  def tag_update
  	report = ImpactReport.find(params[:id])
    report.progress_markers.clear
    if params[:pm_ids] and params[:pm_ids].count > 0
    	params[:pm_ids].each do |pm_id|
        report.progress_markers << ProgressMarker.find(pm_id)
      end
    end
    # send all the necessary data back to the client js
    # so it can adjust the dom to reflect the changes
    # (this is probably not the best way to do this)
    return_data = Array.new
  	report.progress_markers.each do |pm|
      #return_data.push "#{pm.id}_#{pm.name}_#{pm.description}_#{pm.topic.colour}"
      pm_hash = {
        id: pm.id,
        name: pm.name,
        description: pm.description,
        colour: pm.topic.colour
      }
      return_data.push pm_hash.to_json
    end
    render json: return_data
  end

    private

    def impact_report_params
      params.require(:impact_report).permit(:content, :state, :geo_state_id)
    end

end
