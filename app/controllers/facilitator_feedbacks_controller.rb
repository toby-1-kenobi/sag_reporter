class FacilitatorFeedbacksController < ApplicationController

  def create
    @facilitator_feedback = FacilitatorFeedback.create(facilitator_feedback_params)
    respond_to :js
  end

  def update
    @facilitator_feedback = FacilitatorFeedback.find params[:id]
    @facilitator_feedback.update_attributes(facilitator_feedback_params)
    respond_to :js
  end

  private

  def facilitator_feedback_params
    params.require(:facilitator_feedback).permit(
        :result_feedback,
        :report_approved,
        :church_ministry_id,
        :month,
        :progress
    )
  end

end
