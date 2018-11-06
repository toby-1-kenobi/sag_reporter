class SupervisorFeedbacksController < ApplicationController

  def update
    @supervisor_feedback = SupervisorFeedback.find params[:id]
    @supervisor_feedback.update_attributes(supervisor_feedback_params)
    respond_to :js
  end

  private

  def supervisor_feedback_params
    params.require(:supervisor_feedback).permit([:result_feedback, :report_approved])
  end

end
