class Topic < ActiveRecord::Base

	has_and_belongs_to_many :reports
  has_many :progress_markers
  has_many :impact_reports, through: :progress_markers
	has_many :tallies
	has_many :output_tallies, dependent: :destroy

	def max_outcome_score
		score = 0
		progress_markers.active.each do |pm|
			score += pm.weight * ProgressMarker.spread_text.keys.max
		end
		return score
	end
	
end
