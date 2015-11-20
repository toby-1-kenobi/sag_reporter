class LanguageProgress < ActiveRecord::Base

  # This model corresponds to the outcome progress
  # on a particular progress marker for a particular language.
  # WARNING: it doesn't correspond to a particular geo_state.
  # The language may be accross multiple geo_states
  # the progress_updates each have a corresponding geo_state.

  belongs_to :language
  belongs_to :progress_marker
  has_many :progress_updates, dependent: :destroy

  def last_updated
  	progress_updates.maximum('created_at')
  end

  def current_value(geo_state = nil)
    if geo_state
      progress_updates.where(geo_state: geo_state).empty? ? 0 : progress_updates.where(geo_state: geo_state).order("created_at").last.progress
    else
      # This gives you the latest update across the whole language
      # I don't think it's very useful since all updates are by state
    	progress_updates.empty? ? 0 : progress_updates.order("created_at").last.progress
    end
  end

  def month_score(geo_state, year = Date.today.year, month = Date.today.month)
  	cutoff = Date.new(year, month, -1)
  	progress_updates.where(geo_state: geo_state).where("created_at < ?", cutoff).empty? ? 0 : progress_updates.where("created_at < ?", cutoff).last.progress * progress_marker.weight
  end

end

