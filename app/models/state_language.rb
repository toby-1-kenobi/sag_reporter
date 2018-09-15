class StateLanguage < ActiveRecord::Base

  belongs_to :geo_state
  belongs_to :language
  has_many :language_progresses, dependent: :destroy
  has_many :progress_updates, through: :language_progresses
  has_many :church_teams, dependent: :restrict_with_error
  has_many :language_streams, dependent: :destroy
  has_many :facilitators, through: :language_streams, class_name: 'User'

  delegate :name, to: :language, prefix: true
  delegate :name, to: :geo_state, prefix: 'state'
  delegate :colour, to: :language, prefix: true
  delegate :zone, to: :geo_state

  validates :geo_state, presence: true
  validates :language, presence: true

  scope :in_project, -> { where project: true }
  scope :not_in_project, -> { where project: false }

  # The date from which charting of outcome dat should start
  BASE_DATE = Date.new(2016, 10)

  def <=>(sl)
    language.name.downcase <=> sl.language.name.downcase
  end

  def outcome_table_data(user, options = {})
    options[:from_date] ||= 12.months.ago
    if options[:from_date] < BASE_DATE
      options[:from_date] = BASE_DATE
    end
    options[:to_date] ||= Date.today

    table = Rails.cache.fetch(
        "outcome_table_data_#{id}_#{options[:from_date].year}-#{options[:from_date].month}_#{options[:to_date].year}-#{options[:to_date].month}",
        expires_in: 2.weeks,
        backup: true
    ) do

      # this hash for one less db query
      outcome_area_ids = Hash.new

      table = Hash.new
      table['content'] = Hash.new
      table['Totals'] = Hash.new

      all_lps = language_progresses.includes({:progress_marker => :topic}, :progress_updates)
      all_lps.each do |lp|
        unless lp.progress_marker.topic.hide_for?(user)
          oa_name = lp.progress_marker.topic.name
          outcome_area_ids[oa_name] ||= lp.progress_marker.topic_id
          table['content'][oa_name] ||= Hash.new
          lp.outcome_scores(options[:from_date], options[:to_date]).each do |date, score|
            table['content'][oa_name][date] ||= 0
            table['content'][oa_name][date] += score
            table['Totals'][date] ||= 0
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
      end
      table
    end
    if table['content'].any?
      table
    else
      nil
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

  # get percentage score for each outcome area at two dates
  def transformation(user, date_1, date_2)
    # associate progress marker ids with Outcome Area names
    pm_data = Rails.cache.fetch('pm_data', expires_in: 1.day) do
      pm_oa_names = {}
      hidden_pms = []
      pm_weight = {}
      ProgressMarker.includes(:topic).find_each do |pm|
        pm_oa_names[pm.id] = pm.topic.name
        hidden_pms << pm.id if pm.topic.hide_for?(user)
        pm_weight[pm.id] = pm.weight
      end
      {pm_oa_names: pm_oa_names, hidden_pms: hidden_pms, pm_weight: pm_weight}
    end
    # go through every language_progress for this state_language
    # (there's one for each progress marker used)
    # and get it's score at each of the dates
    # and total these scores by outcome area
    transformation = { date_1 => Hash.new {0}, date_2 => Hash.new {0} }
    language_progresses.includes(:progress_updates).find_each do |lp|
      # don't include outcome areas that should be invisible to the user
      unless pm_data[:hidden_pms].include? lp.progress_marker_id
        oa_name = pm_data[:pm_oa_names][lp.progress_marker_id]
        scores = lp.double_month_score(date_1.year, date_1.month, date_2.year, date_2.month, pm_data[:pm_weight])
        transformation[date_1][oa_name] += scores.first
        transformation[date_2][oa_name] += scores.last
      end
    end
    # we need the max possible score for each outcome area to make our scores a percentage
    # this shouldn't change, but it's a bad idea to assume it wont,
    # but we don't want to have to calculate it every time we run this method so cache it.
    max_scores = Rails.cache.fetch('max_scores', expires_in: 1.day) do
      scores = {}
      Topic.find_each do |outcome_area|
        scores[outcome_area.name] = outcome_area.max_outcome_score
      end
      scores
    end
    transformation.each do |date, all_scores|
      all_scores.each do |oa_name, score|
        transformation[date][oa_name] = (score * 100).fdiv(max_scores[oa_name])
      end
    end
    transformation
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

  # return the date that progress levels were last set
  def progress_last_set
    if progress_updates.any?
      pu = progress_updates.order(:year, :month).last
      Date.new(pu.year, pu.month)
    else
      nil
    end
  end

  # get percentage score for each outcome area at current date
  def transformation_data(user, include_overall = false, progress_updates_hash = nil)
    # associate progress marker ids with Outcome Area names
    pm_data = Rails.cache.fetch('pm_data', expires_in: 1.day) do
      pm_oa_names = {}
      hidden_pms = []
      pm_weight = {}
      ProgressMarker.includes(:topic).find_each do |pm|
        pm_oa_names[pm.id] = pm.topic.name
        hidden_pms << pm.id if pm.topic.hide_for?(user)
        pm_weight[pm.id] = pm.weight
      end
      {pm_oa_names: pm_oa_names, hidden_pms: hidden_pms, pm_weight: pm_weight}
    end
    # go through every language_progress for this state_language
    # (there's one for each progress marker used)
    # and get it's score at each of the dates
    # and total these scores by outcome area
    transformation = Hash.new {0}
    language_progresses.each do |lp|
      # don't include outcome areas that should be invisible to the user
      unless pm_data[:hidden_pms].include? lp.progress_marker_id
        oa_name = pm_data[:pm_oa_names][lp.progress_marker_id]
        scores = lp.current_month_score(pm_data[:pm_weight], progress_updates_hash)
        transformation[oa_name] += scores.first
        transformation['Overall'] += scores.first if include_overall
      end
    end
    # we need the max possible score for each outcome area to make our scores a percentage
    # this shouldn't change, but it's a bad idea to assume it wont,
    # but we don't want to have to calculate it every time we run this method so cache it.
    max_scores = Rails.cache.fetch('max_scores', expires_in: 1.day) do
      scores = {}
      Topic.find_each do |outcome_area|
        scores[outcome_area.name] = outcome_area.max_outcome_score
      end
      scores
    end
    if include_overall and not max_scores['Overall']
      max_overall_score = max_scores.values.sum
      max_scores['Overall'] = max_overall_score
    end
    transformation.each do |oa_name, score|
        transformation[oa_name] = (score * 100).fdiv(max_scores[oa_name])
    end
    transformation
  end

end
