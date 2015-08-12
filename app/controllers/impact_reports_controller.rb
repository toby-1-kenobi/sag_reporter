class ImpactReportsController < ApplicationController

  before_action :require_login

  def show
  	@report = ImpactReport.find(params[:id])
  end

  def tag
  	@reports = ImpactReport.where(progress_marker: nil)
  	@outcome_areas = Topic.all
  	@progress_markers_by_oa = ProgressMarker.all.group_by{ |pm| pm.topic }
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

end
