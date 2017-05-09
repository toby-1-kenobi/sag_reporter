class FinishLineProgress < ActiveRecord::Base

  enum status: {
      # 0-3 are options for not done markers
      no_need: 0,
      potential_need: 1,
      expressed_needs: 2,
      in_progress: 3,
      # 4-6 are options for done markers
      no_further_needs_expressed: 4,
      further_needs_expressed: 5,
      further_work_in_progress: 6
  }

  belongs_to :language
  belongs_to :finish_line_marker

  validates :status, presence: true

  def to_s
    "#{finish_line_marker.name} for #{language.name}"
  end

  def complete?
    no_further_needs_expressed? or further_needs_expressed? or further_work_in_progress?
  end

  def human_status
    "#{complete? ? 'Completed' : 'Not completed'}, #{status.humanize}"
  end

end
