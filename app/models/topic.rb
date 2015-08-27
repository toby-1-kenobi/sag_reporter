class Topic < ActiveRecord::Base

	has_and_belongs_to_many :reports
  has_many :progress_markers
  has_many :impact_reports, through: :progress_markers
	has_many :tallies
	has_many :output_tallies, dependent: :destroy
	
end
