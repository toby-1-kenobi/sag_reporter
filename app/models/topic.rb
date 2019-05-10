class Topic < ActiveRecord::Base

  has_paper_trail

	has_and_belongs_to_many :reports
  has_many :progress_markers
  has_many :impact_reports, through: :progress_markers
	has_many :tallies
	has_many :output_tallies, dependent: :destroy

  validates :name, presence: true
  validates :number, presence: true

	def max_outcome_score
		score = 0
		progress_markers.active.each do |pm|
			score += pm.weight * ProgressMarker.spread_text.keys.max
		end
		return score
	end

	def hide_for?(user)
    hide_on_alternate_pm_description? and user.sees_alternate_pm_descriptions?
	end
	
end
