class GeoState < ActiveRecord::Base

  belongs_to :zone
  has_many :users
  has_many :state_languages
  has_many :languages, through: :state_languages
  has_many :reports
  has_many :impact_reports
  has_many :mt_resources
  has_many :events
  has_many :people
  has_many :output_counts
  has_many :progress_updates
  has_many :districts, dependent: :destroy

  def zone_id
    zone.id
  end

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
  
end
