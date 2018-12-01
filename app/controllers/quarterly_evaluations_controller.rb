class QuarterlyEvaluationsController < ApplicationController

  before_action :require_login

  def update
    @quarterly_evaluation = QuarterlyEvaluation.find(params[:id])
    @quarterly_evaluation.update_attributes(quarterly_evaluation_params)
    respond_to :js
  end

  private

  def quarterly_evaluation_params
    params.require(:quarterly_evaluation).permit(
        :question_1,
        :question_2,
        :question_3,
        :question_4,
        :report_id,
        :comment,
        :progress,
        :approved
    )
  end
end
