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
    redirect_to root_path unless logged_in_user.trusted?
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
    date_range = @date..@date.at_end_of_month.to_date
    geo_state_ids = logged_in_user.geo_states.pluck :id
  	@reports = ImpactReport.
      includes(
        :progress_markers,
        :report => [:geo_state, :languages, :topics]
      ).
      where(
        'reports.status' => "active",
        'reports.geo_state_id' => geo_state_ids,
        'reports.report_date' => date_range
      )
  	@outcome_areas = Topic.all
  	@progress_markers_by_oa = ProgressMarker.active.includes(:topic).all.group_by{ |pm| pm.topic }
    #Todo: Switch to project languages instead of minority languages.
    @languages = Language.minorities(logged_in_user.geo_states).order("LOWER(languages.name)")
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
        number: pm.number,
        description: pm.description_for(logged_in_user),
        colour: pm.topic.colour
      }
      return_data.push pm_hash.to_json
    end
    render json: return_data
  end

  def not_impact
    report = ImpactReport.find(params[:id])
    report.make_not_impact
    render nothing: true
  end

  def shareable
    report = ImpactReport.find(params[:id])
    report.shareable = true
    report.save
    render nothing: true
  end

  def not_shareable
    report = ImpactReport.find(params[:id])
    report.shareable = false
    report.save
    render nothing: true
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
