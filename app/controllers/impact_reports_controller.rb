class ImpactReportsController < ApplicationController

  before_action :require_login

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
  end

  def tag_update
  	report = ImpactReport.find(params[:id])
  	progress_marker = ProgressMarker.find(params[:pm_id])
  	report.progress_marker = progress_marker
  	if report.save
  	  render text: "success report: #{params[:id]} pm: #{params[:pm_id]}"
  	else
  	  render text: "fail report: #{params[:id]} pm: #{params[:pm_id]}"
  	end
  end

    private

    def impact_report_params
      params.require(:impact_report).permit(:content, :state, :geo_state_id)
    end

end
