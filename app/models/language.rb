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

  validates :name, presence: true, allow_nil: false, uniqueness: true

  def self.minorities
    where(lwc: false)
  end

  def table_data(options = {})
    options[:from_date] ||= 1.year.ago - 1.month
    options[:to_date] ||= 1.month.ago
    dates_by_month = (options[:from_date].to_date..options[:to_date].to_date).select{ |d| d.day == 1}

    table = Array.new

    headers = ["Outputs"]
    dates_by_month.each{ |date| headers.push(date.strftime("%B %Y")) }
    table.push(headers)

    OutputTally.all.order(:topic_id).each do |tally|
      row = [tally.description]
      dates_by_month.each do |date|
        row.push(tally.total([self], date.year, date.month))
      end
      table.push(row)
    end

    return table

  end

  def outcome_month_score(outcome_area, year = Date.today.year, month = Date.today.month)
    LanguageProgress.includes(:progress_marker).where(language: self, "progress_markers.topic_id" => outcome_area.id).inject(0){ |sum, lp| sum + lp.month_score(year, month) }
  end

  def total_month_score(year = Date.today.year, month = Date.today.month)
    Topic.all.inject(0){ |sum, oa| sum + outcome_month_score(oa, year, month) }
  end

  def outcome_table_data(options = {})
    options[:from_date] ||= 1.year.ago - 1.month
    options[:to_date] ||= 1.month.ago
    dates_by_month = (options[:from_date].to_date..options[:to_date].to_date).select{ |d| d.day == 1}

    table = Array.new

    headers = ["Outcome Areas"]
    dates_by_month.each{ |date| headers.push(date.strftime("%B %Y")) }
    table.push(headers)

    Topic.all.each do |outcome_area|
      row = [outcome_area.name]
      dates_by_month.each do |date|
        row.push(outcome_month_score(outcome_area, date.year, date.month))
      end
      table.push(row)
    end

    table.push(["Totals"] + dates_by_month.map{ |d| total_month_score(d.year, d.month) })

    return table
  end

  def get_interface_fallback
    Language.find_by_name("English") || Language.take
  end
	
end
