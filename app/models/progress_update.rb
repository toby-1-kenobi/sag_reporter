class ProgressUpdate < ActiveRecord::Base

  #TODO: Make this not state based. Delegate geo_state through language_progress to state_language
  include StateBased
	
  belongs_to :user
  belongs_to :language_progress
  delegate :language, to: :language_progress

  validates :progress, presence: true, inclusion: ProgressMarker.spread_text.keys
  validates :month, presence: true, inclusion: 1..12
  validates :year, presence: true, inclusion: 2000..Time.now.year
  validates :user, presence: true
  validates :language_progress, presence: true

  def progress_date
    Date.new(self.year, self.month, -1).end_of_day
  end

  def <=>(pu)
    progress_date == pu.progress_date ? created_at <=> pu.created_at : progress_date <=> pu.progress_date
  end

end
