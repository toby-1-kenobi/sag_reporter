class QuarterlyEvaluationsController < ApplicationController

  before_action :require_login

  def update
    @quarterly_evaluation = QuarterlyEvaluation.find(params[:id])
    @quarterly_evaluation.update_attributes(quarterly_evaluation_params)
    respond_to :js
  end

  def select_report
    @quarterly_evaluation = QuarterlyEvaluation.find(params[:id])
    @quarterly_evaluation.report_id = params[:report]
    Rails.logger.error(@quarterly_evaluation.errors.full_messages) unless @quarterly_evaluation.save
    respond_to :js
  end

  def add_report
    @quarterly_evaluation = QuarterlyEvaluation.find(params[:id])
    report = Report.create(
                                    reporter: logged_in_user,
                                    content: 'Type the impact story here',
                                    geo_state: @quarterly_evaluation.state_language.geo_state,
                                    report_date: last_day_of_quarter(@quarterly_evaluation.quarter),
                                    impact_report: ImpactReport.new(),
                                    project: @quarterly_evaluation.project
    )
    if report.persisted?
      report.languages << @quarterly_evaluation.state_language.language
      report.ministries << @quarterly_evaluation.ministry
      @quarterly_evaluation.update_attributes(report: report)
    else
      Rails.logger.error("unable to create a new report for quarterly evaluation #{@quarterly_evaluation.id}")
      Rails.logger.error(report.errors.full_messages)
    end
    @reports = Report.joins(:languages).where('languages.id = ?', @quarterly_evaluation.state_language.language)
    render 'select_report'
  end

  private

  def quarterly_evaluation_params
    params.require(:quarterly_evaluation).permit(
        :improvements,
        :question_1,
        :question_2,
        :question_3,
        :question_4,
        :progress,
        :approved
    )
  end

  def last_day_of_quarter(quarter)
    year = quarter[0..3].to_i
    q = quarter[-1].to_i
    month = ((q - 1)*3 + Rails.configuration.year_cutoff_month + 1) % 12 + 1
    if Rails.configuration.year_cutoff_month >= 6
      year = month < Rails.configuration.year_cutoff_month ? year : year - 1
    else
      year = month >= Rails.configuration.year_cutoff_month ? year : year + 1
    end
    Date.new(year, month).end_of_month - 1.day
  end

end
