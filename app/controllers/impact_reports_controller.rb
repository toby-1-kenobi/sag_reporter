class ImpactReportsController < ApplicationController

  def show
  	@report = ImpactReport.find(params[:id])
  end

end
