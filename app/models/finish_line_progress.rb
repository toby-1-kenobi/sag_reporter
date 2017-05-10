class FinishLineProgress < ActiveRecord::Base

  enum status: {
      # 0-3 are options for not done markers
      not_completed_no_need: 0,
      not_completed_potential_need: 1,
      not_completed_expressed_needs: 2,
      not_completed_in_progress: 3,
      # 4-6 are options for done markers
      completed_no_further_needs_expressed: 4,
      completed_further_needs_expressed: 5,
      completed_further_work_in_progress: 6
  }

  belongs_to :language
  belongs_to :finish_line_marker

  validates :status, presence: true

  def to_s
    "#{finish_line_marker.name} for #{language.name}"
  end

  def complete?
    completed_no_further_needs_expressed? or completed_further_needs_expressed? or completed_further_work_in_progress?
  end

  def human_status
    "#{complete? ? 'Completed' : 'Not completed'}, #{status.humanize}"
  end

end
