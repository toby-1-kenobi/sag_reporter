module ReportFilter
  extend ActiveSupport::Concern

  private

  # strong parameters for report filtering
  def report_filter_params
    params.permit(
        :archived,
        :significant,
        :since,
        :until,
        {:types => []},
        :report_types,
        :translation_impact
    )
  end

end