class MinistryOutputsController < ApplicationController

  before_action :require_login

  def update
    @ministry_output = MinistryOutput.find params[:id]
    @ministry_output.update_attributes(ministry_output_params)
    respond_to :js
  end

  def create
    @ministry_output = MinistryOutput.new(ministry_output_params)
    unless @ministry_output.save
      Rails.logger.error("could not create ministry output record: #{@ministry_output.errors.full_messages}")
    end
    respond_to do |format|
      format.js { render :update }
    end
  end

  private

  def ministry_output_params
    params.require('ministry_output').permit(
        :value,
        :church_ministry_id,
        :deliverable_id,
        :creator_id,
        :month,
        :actual
    )
  end

end
