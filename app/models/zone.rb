class Zone < ActiveRecord::Base

  enum pm_description_type: {
      default: 0,
      alternate: 1
  }

  has_many :geo_states
  has_many :users, through: :geo_states
  has_many :languages, through: :geo_states
  has_many :state_languages, through: :geo_states
  has_many :engaged_organisations, through: :geo_states
  has_many :translating_organisations, through: :geo_states

  def self.of_states(geo_states)
    geo_states.collect{ |gs| gs.zone }.uniq
  end

  def self.national_outcome_chart_data
    from_date = 12.months.ago
    to_date = Date.today
    table_data = Hash.new
    all_lps = LanguageProgress.includes({:progress_marker => :topic}, :progress_updates).all
    all_lps.find_each do |lp|
      oa_name = lp.progress_marker.topic.name
      table_data[oa_name] ||= Hash.new {0}
      lp.outcome_scores(from_date, to_date).each do |date, score|
        table_data[oa_name][date] += score
      end
    end
    chart_data = Array.new
    table_data.each do |row_name, table_row|
      chart_row = {name: row_name, data: table_row}
      chart_data.push(chart_row)
    end
    chart_data
  end

end
