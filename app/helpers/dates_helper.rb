module DatesHelper
  def current_quarter
    Date.today.month + 12 - Rails.configuration.year_cutoff_month
  end
end
