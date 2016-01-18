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

  def tagged_impact_report_count(from_date = nil, to_date = nil)
    if from_date
      to_date ||= Date.today
      ImpactReport.active.joins(:progress_markers).where.not('progress_markers.id' => nil).where(geo_state: self, report_date: from_date..to_date).uniq.count
    elsif to_date
      ImpactReport.active.joins(:progress_markers).where.not('progress_markers.id' => nil).where(geo_state: self).where('report_date <= ?', to_date).uniq.count
    else
      ImpactReport.active.joins(:progress_markers).where.not('progress_markers.id' => nil).where(geo_state: self).uniq.count
    end
  end
  
end
