class Language < ActiveRecord::Base

  has_many :user_mt_speakers, class_name: 'User', foreign_key: 'mother_tongue_id'
  has_and_belongs_to_many :user_speakers, class_name: 'User'
  has_and_belongs_to_many :reports
  has_many :language_tallies, class_name: 'LanguagesTally', dependent: :destroy
  has_and_belongs_to_many :impact_reports
  has_many :tallies, through: :language_tallies
  has_and_belongs_to_many :events
  has_many :language_progresses, dependent: :destroy
  has_many :progress_markers, through: :language_progresses
  has_many :output_counts
  has_many :mt_resources
  has_and_belongs_to_many :geo_states

  validates :name, presence: true, allow_nil: false, uniqueness: true

  def self.minorities(geo_state = nil)
    if geo_state
      includes(:geo_states).where(lwc: false, "geo_states.id" => geo_state.id)
    else
      where(lwc: false)
    end
  end

  def self.interface_fallback
    Language.find_by_name("English") || Language.take
  end

  def table_data(geo_state, options = {})
    options[:from_date] ||= 6.months.ago
    options[:to_date] ||= Date.today
    dates_by_month = (options[:from_date].to_date..options[:to_date].to_date).select{ |d| d.day == 1}

    table = Array.new

    headers = ["Outputs"]
    dates_by_month.each{ |date| headers.push(date.strftime("%B %Y")) }
    table.push(headers)

    OutputTally.all.order(:topic_id).each do |tally|
      row = [tally.description]
      dates_by_month.each do |date|
        row.push(tally.total(geo_state, [self], date.year, date.month))
      end
      table.push(row)
    end

    resources_row = ['Number of tools completed by the network']
    dates_by_month.each_with_index do |date, index|
      resources_row.push(MtResource.where(geo_state: geo_state, language: self, created_at: date..(dates_by_month[index + 1] || date + 1.month)).count)
    end
    table.push(resources_row)

    return table

  end

  def outcome_month_score(geo_state, outcome_area, year = Date.today.year, month = Date.today.month)
    LanguageProgress.includes(:progress_marker).where(language: self, "progress_markers.topic_id" => outcome_area.id).inject(0){ |sum, lp| sum + lp.month_score(geo_state, year, month) }
  end

  def total_month_score(geo_state, year = Date.today.year, month = Date.today.month)
    Topic.all.inject(0){ |sum, oa| sum + outcome_month_score(geo_state, oa, year, month) }
  end

  def outcome_table_data(geo_state, options = {})
    options[:from_date] ||= 6.months.ago
    options[:to_date] ||= Date.today
    dates_by_month = (options[:from_date].to_date..options[:to_date].to_date).select{ |d| d.day == 1}

    table = Array.new

    headers = ["Outcome Areas"]
    dates_by_month.each{ |date| headers.push(date.strftime("%B %Y")) }
    table.push(headers)

    Topic.all.each do |outcome_area|
      row = [outcome_area.name]
      dates_by_month.each do |date|
        row.push(outcome_month_score(geo_state, outcome_area, date.year, date.month))
      end
      table.push(row)
    end

    table.push(["Totals"] + dates_by_month.map{ |d| total_month_score(d.year, d.month) })

    return table
  end

  def outcome_chart_data(geo_state, options = {})
    table_data = outcome_table_data(geo_state, options)
    headers = table_data.shift
    headers.shift
    chart_data = Array.new
    table_data.each do |table_row|
      chart_row = {name: table_row.shift, data: {}}
      table_row.each_with_index do |datum, index|
        chart_row[:data][headers[index]] = datum
      end
      chart_data.push(chart_row)
    end
    return chart_data
  end
	
end
