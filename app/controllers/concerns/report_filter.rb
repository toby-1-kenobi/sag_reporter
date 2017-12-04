module ReportFilter
  extend ActiveSupport::Concern

  include ParamsHelper

  private

  # strong parameters for report filtering
  def report_filter_params
    param_reduce(params, ['states'])
    Rails.logger.debug params
    params.permit(
        :archived,
        :significant,
        :since,
        :until,
        {:types => []},
        :report_types,
        :translation_impact,
        :states_filter,
        {:states => []}
    )
  end

end