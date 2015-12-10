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
      progress_updates.where(geo_state: geo_state).empty? ? 0 : progress_updates.where(geo_state: geo_state).order("year, month, created_at").last.progress
    else
      # This gives you the latest update across the whole language
      # I don't think it's very useful since all updates are by state
    	progress_updates.empty? ? 0 : progress_updates.order("year, month, created_at").last.progress
    end
  end

  # find the latest progress update in or before a given month
  # and use this to get the score for that month
  def month_score(geo_state, year = Date.today.year, month = Date.today.month)
  	cutoff = Date.new(year, month, -1).end_of_day
    state_updates = progress_updates.where(geo_state: geo_state).select{ |pu| pu.progress_date <= cutoff }
    # if more than one update shares the same progress_date then max_by will select the first of these
    # we want the one added most recently so we reverse sort by created_at
  	return state_updates.empty? ? 0 : state_updates.sort{ |a,b| b.created_at <=> a.created_at }.max_by(&:progress_date).progress * progress_marker.weight
  end

end

