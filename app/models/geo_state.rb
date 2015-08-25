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
  
end
