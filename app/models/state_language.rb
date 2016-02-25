class StateLanguage < ActiveRecord::Base

  belongs_to :geo_state
  belongs_to :language
  has_many :language_progresses
  has_many :progress_updates, through: :language_progresses

  delegate :name, to: :language, prefix: true
  delegate :name, to: :geo_state, prefix: 'state'
  delegate :colour, to: :language, prefix: true

  validates :geo_state, presence: true
  validates :language, presence: true

  scope :in_project, -> { where project: true }

  def <=>(sl)
    language.name.downcase <=> sl.language.name.downcase
  end

  def outcome_table_data(options = {})
    options[:from_date] ||= 6.months.ago
    options[:to_date] ||= Date.today

    table = Hash.new
    table["content"] = Hash.new
    table["Totals"] = Hash.new

    all_lps = language_progresses.includes({:progress_marker => :topic}, :progress_updates)
    all_lps.each do |lp|
      oa_name = lp.progress_marker.topic.name
      table["content"][oa_name] ||= Hash.new
      lp.outcome_scores(options[:from_date], options[:to_date]).each do |date, score|
        table["content"][oa_name][date] ||= 0
        table["content"][oa_name][date] += score
        table["Totals"][date] ||= 0
        table["Totals"][date] += score
      end
    end
    if table["content"].any?
      return table
    else
      return nil
    end
  end

  # convert the table data into a format ChartKick can use
  def outcome_chart_data(options = {})
    table_data = outcome_table_data(options)
    if table_data
      chart_data = Array.new
      table_data["content"].each do |row_name, table_row|
        chart_row = {name: row_name, data: table_row}
        chart_data.push(chart_row)
      end
      return chart_data
    else
      return nil
    end
  end

end
