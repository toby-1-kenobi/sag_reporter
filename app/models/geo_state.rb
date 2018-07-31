class GeoState < ActiveRecord::Base

  belongs_to :zone
  has_and_belongs_to_many :users
  has_many :state_languages, dependent: :destroy
  has_many :languages, through: :state_languages, after_add: :update_self, after_remove: :update_self
  has_many :reports, dependent: :restrict_with_error
  has_many :impact_reports
  has_many :mt_resources, dependent: :restrict_with_error
  has_many :events
  has_and_belongs_to_many :people
  has_many :output_counts
  has_many :progress_updates #this relationship seems unnecessary because it should go through state_languages
  has_many :districts, dependent: :destroy
  has_many :villages, dependent: :destroy
  has_many :curatings, dependent: :destroy
  has_many :curators, through: :curatings, class_name: 'User', source: 'user', inverse_of: :curated_states
  has_and_belongs_to_many :edits
  has_many :engaged_organisations, through: :languages
  has_many :translating_organisations, through: :languages
  delegate :name, to: :zone, prefix: true

  def minority_languages
    self.languages.where(lwc: false)
  end

  def tagged_impact_report_count(from_date = nil, to_date = nil)
    if from_date
      to_date ||= Date.today
      tagged_impact_reports.where(
        :reports => {
          report_date: from_date..to_date
        }
      ).count
    elsif to_date
      tagged_impact_reports.where('reports.report_date <= ?', to_date).count
    else
      tagged_impact_reports.count
    end
  end

  def tagged_impact_reports
    ImpactReport.
      joins(:report, :progress_markers).
      where(
        :reports => {
          status: "active",
          geo_state_id: self.id
        }
      ).distinct
  end

  def languages_total_chart_data(user)
    combined_data = Hash.new
    outcomes_data(user).values.each do |language_data|
      if language_data
        language_data["content"].each do |oa_name, oa_data|
          oa_data.each do |date, value|
            combined_data[oa_name] ||= Hash.new
            combined_data[oa_name][date] ||= 0
            combined_data[oa_name][date] += value
          end
        end
      end
    end
    chart_data = Array.new
    combined_data.each do |oa_name, oa_data|
      if oa_data.any?
        chart_row = {
          name: oa_name,
          data: oa_data
        }
        chart_data.push(chart_row)
      end
    end
    return chart_data
  end

  def outcome_totals_chart_data(user)
    chart_data = Array.new
    outcomes_data(user).each do |state_language, data|
      if data
        chart_row = {
          name: state_language.language_name,
          data: data["Totals"]
        }
        chart_data.push(chart_row)
      end
    end
    return chart_data
  end

  def outcome_area_chart_data(outcome_area, user)
    chart_data = Array.new
    outcomes_data(user).each do |state_language, data|
      if data
        chart_row = {
          name: state_language.language_name,
          data: data["content"][outcome_area.name]
        }
        chart_data.push(chart_row)
      end
    end
    return chart_data
  end

  def update_self object
    self.touch if self.persisted?
  end

  private

  def outcomes_data(user)
    data = Hash.new
    state_languages.in_project.includes(:language_progresses => [{:progress_marker => :topic}, :progress_updates]).each do |state_language|
      data[state_language] = state_language.outcome_table_data(user)
    end
    return data
  end
  
end
