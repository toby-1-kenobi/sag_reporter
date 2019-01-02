class QuarterlyEvaluationsController < ApplicationController

  before_action :require_login

  def update
    @quarterly_evaluation = QuarterlyEvaluation.find(params[:id])
    @quarterly_evaluation.update_attributes(quarterly_evaluation_params)
    if params['report_content']
      @quarterly_evaluation.report.update_attributes(content: params['report_content'])
    end
    respond_to :js
  end

  def select_report
    @quarterly_evaluation = QuarterlyEvaluation.find(params[:id])
    @quarterly_evaluation.report_id = params[:report]
    Rails.logger.error(@quarterly_evaluation.errors.full_messages) unless @quarterly_evaluation.save
    respond_to :js
  end

  private

  def quarterly_evaluation_params
    params.require(:quarterly_evaluation).permit(
        :question_1,
        :question_2,
        :question_3,
        :question_4,
        :progress,
        :approved
    )
  end
end
