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
