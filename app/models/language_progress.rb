class LanguageProgress < ActiveRecord::Base

  belongs_to :language
  belongs_to :progress_marker
  has_many :progress_updates, dependent: :destroy

  def last_updated
  	progress_updates.maximum('created_at')
  end

  def current_value
  	progress_updates.empty? ? 0 : progress_updates.order("created_at").last.progress
  end

  def month_score(year = Date.today.year, month = Date.today.month)
  	cutoff = Date.new(year, month, -1)
  	progress_updates.where("created_at < ?", cutoff).empty? ? 0 : progress_updates.where("created_at < ?", cutoff).last.progress * progress_marker.weight
  end

end

