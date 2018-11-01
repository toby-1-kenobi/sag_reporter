module DatesHelper

  def current_quarter
    1 + ((Date.today.month - Rails.configuration.year_cutoff_month) % 12) / 3
  end

  def months_in_quarter(q)
    start = (q - 1)*3 + Rails.configuration.year_cutoff_month
    [start, start + 1, start + 2].map{ |m| (m - 1) % 12 + 1 }
  end

end
