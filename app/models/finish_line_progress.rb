class FinishLineProgress < ActiveRecord::Base

  enum status: {
      # 0-3 are options for not done markers
      no_need: 0,
      potential_need: 1,
      expressed_needs: 2,
      in_progress: 3,
      # 4-6 are options for done markers
      no_further_expressed_needs: 4,
      further_expressed_needs: 5,
      further_steps_in_progress: 6
  }

  belongs_to :language
  belongs_to :finish_line_marker

  validates :status, presence: true

  def complete
    no_further_expressed_needs? or further_expressed_needs? or further_steps_in_progress?
  end

end
