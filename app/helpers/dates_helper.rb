module DatesHelper

  def app_year(year, month)
    if Rails.configuration.year_cutoff_month >= 6
      month < Rails.configuration.year_cutoff_month ? year : year + 1
    else
      month >= Rails.configuration.year_cutoff_month ? year : year - 1
    end
  end

  def year_from_app_year(app_year, month)
    if Rails.configuration.year_cutoff_month >= 6
      month < Rails.configuration.year_cutoff_month ? app_year : app_year - 1
    else
      month >= Rails.configuration.year_cutoff_month ? app_year : app_year + 1
    end
  end

  def quarter_for_month(month)
    1 + ((month - Rails.configuration.year_cutoff_month) % 12) / 3
  end

  def app_quarter(year, month)
    "#{app_year(year, month)}-#{quarter_for_month(month)}"
  end

  def months_in_quarter(q)
    start = (q - 1)*3 + Rails.configuration.year_cutoff_month
    [start, start + 1, start + 2].map{ |m| (m - 1) % 12 + 1 }
  end

  def quarter_to_range(quarter)
    months = months_in_quarter(quarter[-1].to_i)
    first_month = "#{year_from_app_year(quarter[0..3].to_i, months.first)}-#{months.first.to_s.rjust(2, '0')}"
    last_month = "#{year_from_app_year(quarter[0..3].to_i, months.last)}-#{months.last.to_s.rjust(2, '0')}"
    [first_month, last_month]
  end

  # take an initial month and final month, return an array with year values added to each month
  # format of array element is "YYYY-MM"
  # Assume months are nearby current date.
  # Take booleans for whether the first month is in the past or not.
  def months_with_year(init, final, init_in_past)
    if (init < Date.today.month)
      year = init_in_past ? Date.today.year : Date.today.year + 1
    else
      year = init_in_past ? Date.today.year - 1 : Date.today.year
    end
    month = Date.new(year, init)
    months = [month.strftime("%Y-%m")]
    done = false
    while not done
      month = month + 1.month
      months << month.strftime("%Y-%m")
      done = month.month == final
    end
    months
  end

  def pretty_month(month)
    date = Date.new(month[0..3].to_i, month[-2..-1].to_i)
    date.strftime('%B %Y')
  end

  def years_of_quarters(years)
    current_year = app_year(Date.today.year, Date.today.month)
    quarters = []
    ((current_year - years + 1)..current_year).each do |year|
      (1..4).each do |quarter|
        quarters << ["#{year} quarter #{quarter}", "#{year}-#{quarter}"]
      end
    end
    quarters
  end

end
