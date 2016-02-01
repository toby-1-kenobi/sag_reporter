class ProgressUpdate < ActiveRecord::Base

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

end
