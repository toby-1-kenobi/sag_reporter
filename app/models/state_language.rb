class StateLanguage < ActiveRecord::Base

  belongs_to :geo_state
  belongs_to :language
  has_many :language_progresses, dependent: :destroy
  has_many :progress_updates, through: :language_progresses

  delegate :name, to: :language, prefix: true
  delegate :name, to: :geo_state, prefix: 'state'
  delegate :colour, to: :language, prefix: true
  delegate :zone, to: :geo_state

  validates :geo_state, presence: true
  validates :language, presence: true

  scope :in_project, -> { where project: true }

  # The date from which charting of outcome dat should start
  BASE_DATE = Date.new(2016, 10)

  def <=>(sl)
    language.name.downcase <=> sl.language.name.downcase
  end

  def outcome_table_data(user, options = {})
    options[:from_date] ||= 6.months.ago
    if options[:from_date] < BASE_DATE
      options[:from_date] = BASE_DATE
    end
    options[:to_date] ||= Date.today

    # this hash for one less db query
    outcome_area_ids = Hash.new

    table = Hash.new
    table['content'] = Hash.new
    table['Totals'] = Hash.new {0}

    all_lps = language_progresses.includes({:progress_marker => :topic}, :progress_updates)
    all_lps.each do |lp|
      unless lp.progress_marker.topic.hide_for?(user)
        oa_name = lp.progress_marker.topic.name
        outcome_area_ids[oa_name] ||= lp.progress_marker.topic_id
        table['content'][oa_name] ||= Hash.new {0}
        lp.outcome_scores(options[:from_date], options[:to_date]).each do |date, score|
          table['content'][oa_name][date] += score
          table['Totals'][date] += score
        end
      end
    end
    if table['content'].any?
      # now express all scores as a percentage of the maximum attainable
      total_divisor = 0
      max_scores = max_outcome_scores
      table['content'].each_key do |oa_name|
        divisor = max_scores[outcome_area_ids[oa_name]]
        if !(divisor > 0)
          divisor = 1
        end
        total_divisor += divisor
        if table['content'][oa_name]
          table['content'][oa_name].each do |date, score|
            table['content'][oa_name][date] = (score * 100).fdiv(divisor)
          end
        end
      end
      table['Totals'].each do |date, score|
        table['Totals'][date] = (score * 100).fdiv(total_divisor)
      end
      return table
    else
      return nil
    end
  end

  # convert the table data into a format ChartKick can use
  def outcome_chart_data(user, options = {})
    table_data = outcome_table_data(user, options)
    if table_data
      chart_data = Array.new
      table_data['content'].each do |row_name, table_row|
        chart_row = {name: row_name, data: table_row}
        chart_data.push(chart_row)
      end
      overall_row = {name: 'Overall score', data: table_data['Totals']}
      chart_data.push(overall_row)
      return chart_data
    else
      return nil
    end
  end

  # The maximum outcome score for a given outcome area
  # discounting all the progress markers where this
  # state_language has not set levels.
  def max_outcome_score(outcome_area)
    score = 0
    language_progresses.with_updates.
        includes(:progress_marker).
        where('progress_markers.topic_id' => outcome_area.id, 'progress_markers.status' => 0).
        find_each do |progress|
      score += progress.progress_marker.weight  * ProgressMarker.spread_text.keys.max
    end
    return score
  end

  # like max_outcome_score, except it returns a hash for each outcome area
  def max_outcome_scores()
    scores = Hash.new(0)
    language_progresses.with_updates.
        includes(:progress_marker).
        where('progress_markers.status' => 0).
        find_each do |progress|
      scores[progress.progress_marker.topic_id] += progress.progress_marker.weight * ProgressMarker.spread_text.keys.max
    end
    return scores
  end

  # active impact reports in this state and tagged with this language in the specified duration.
  def recent_impact_reports(duration)
    ImpactReport.
        includes(:progress_markers, :report => [ :reporter, :languages ]).
        where(
            :reports => {status: 'active', geo_state_id: geo_state_id},
            :languages => {id: language_id},
        ).
        where('reports.report_date >= ?', duration.ago).distinct
  end

end
