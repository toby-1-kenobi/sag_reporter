class StateLanguage < ActiveRecord::Base

  belongs_to :geo_state
  belongs_to :language
  has_many :language_progresses
  has_many :progress_updates, through: :language_progresses

  validates :geo_state, presence: true
  validates :language, presence: true

  def outcome_table_data(options = {})
    options[:from_date] ||= 6.months.ago
    options[:to_date] ||= Date.today
    dates_by_month = (options[:from_date].to_date..options[:to_date].to_date).select{ |d| d.day == 1}

    table = Hash.new
    table["Totals"] = Hash.new

    all_lps = language_progresses.includes(:progress_marker => :topic)
    all_lps.each do |lp|
      oa_name = lp.progress_marker.topic.name
      table[oa_name] ||= Hash.new
      dates_by_month.each do |date|
        score = lp.month_score(date.year, date.month)
        table[oa_name][date.strftime("%B %Y")] ||= 0
        table[oa_name][date.strftime("%B %Y")] += score
        table["Totals"][date.strftime("%B %Y")] ||= 0
        table["Totals"][date.strftime("%B %Y")] += score
      end
    end

    return table
  end

end
