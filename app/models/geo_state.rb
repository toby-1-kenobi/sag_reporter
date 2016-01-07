class GeoState < ActiveRecord::Base

  belongs_to :zone
  has_many :users
  has_and_belongs_to_many :languages
  has_many :reports
  has_many :impact_reports
  has_many :mt_resources
  has_many :events
  has_many :people
  has_many :output_counts
  has_many :progress_updates

  def zone_id
    zone.id
  end

  def minority_languages
    languages.where(lwc: false)
  end

  def impact_report_count(from_date = nil, to_date = nil)
    if from_date
      to_date ||= Date.today
      ImpactReport.where(geo_state: self, report_date: from_date..to_date).count
    elsif to_date
      ImpactReport.where(geo_state: self).where('report_date <= ?', to_date).count
    else
      ImpactReport.where(geo_state: self).count
    end
  end
  
end
