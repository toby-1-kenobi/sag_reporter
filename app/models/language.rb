class Language < ActiveRecord::Base

  has_many :user_mt_speakers, class_name: 'User', foreign_key: 'mother_tongue_id'
  has_and_belongs_to_many :user_speakers, class_name: 'User'
  has_and_belongs_to_many :reports
  has_many :language_tallies, class_name: 'LanguagesTally', dependent: :destroy
  has_many :tallies, through: :language_tallies
  has_and_belongs_to_many :events
  has_many :progress_markers, through: :language_progresses
  has_many :output_counts
  has_many :mt_resources
  has_many :state_languages, dependent: :destroy
  has_many :geo_states, through: :state_languages
  has_many :organisation_engagements
  has_many :engaged_organisations, through: :organisation_engagements, source: :organisation
  has_many :organisation_translations
  has_many :translating_organisations, through: :organisation_translations, source: :organisation
  belongs_to :family, class_name: 'LanguageFamily'
  belongs_to :pop_source, class_name: 'DataSource'
  belongs_to :cluster

  delegate :name, to: :family, prefix: true
  delegate :name, to: :cluster, prefix: true

  validates :name, presence: true, allow_nil: false, uniqueness: true

  def self.minorities(geo_states = nil)
    if geo_states
      includes(:geo_states).where(lwc: false, 'geo_states.id' => geo_states.map{ |s| s.id })
    else
      where(lwc: false)
    end
  end

  def self.interface_fallback
    Language.find_by_name('English') || Language.take
  end

  def geo_state_ids_str
    geo_state_ids.join ','
  end

  def tagged_impact_report_count(geo_state, from_date = nil, to_date = nil)
    tagged_impact_reports_in_date_range(geo_state, from_date, to_date).count
  end

  def tagged_impact_reports_monthly(geo_state, from_date = nil, to_date = nil)
    tagged_impact_reports_in_date_range(geo_state, from_date, to_date).group_by{ |r| r.report_date.strftime('%Y-%m') }
  end

  def table_data(geo_state, options = {})
    options[:from_date] ||= 6.months.ago
    options[:to_date] ||= Date.today
    dates_by_month = (options[:from_date].to_date..options[:to_date].to_date).select{ |d| d.day == 1}

    table = Array.new

    headers = ['Outputs']
    dates_by_month.each{ |date| headers.push(date.strftime('%B %Y')) }
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

  private

  def tagged_impact_reports(geo_state)
    ImpactReport.
      joins(:report, :progress_markers, report: :languages).
      where(
        :reports => {status: 'active', geo_state_id: geo_state.id},
        :languages => {id: self.id},
      ).distinct
  end

  def tagged_impact_reports_in_date_range(geo_state, from_date = nil, to_date = nil)
    if from_date
      to_date ||= Date.today
      tagged_impact_reports(geo_state).where(:reports => {report_date: from_date..to_date})
    elsif to_date
      tagged_impact_reports(geo_state).where('reports.report_date <= ?', to_date)
    else
      tagged_impact_reports(geo_state)
    end
  end

end
