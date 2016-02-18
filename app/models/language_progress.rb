class LanguageProgress < ActiveRecord::Base

  # This model corresponds to the outcome progress
  # on a particular progress marker for a particular language in a state.

  CACHE_TIMEOUT = 5.seconds

  belongs_to :state_language
  belongs_to :progress_marker
  has_many :progress_updates, dependent: :destroy

  validates :progress_marker, presence: true, uniqueness: { scope: :state_language }
  validates :state_language, presence: true

  def last_updated
  	progress_updates.maximum('created_at')
  end

  def progress_updates_geo_state(geo_state)
    @progress_updates_by_state_cache ||= Hash.new
    @progress_updates_by_state_cache_time ||= Hash.new
    
    if !@progress_updates_by_state_cache[geo_state] or @progress_updates_by_state_cache_time[geo_state] < CACHE_TIMEOUT.ago
      @progress_updates_by_state_cache_time[geo_state] = Time.now
      @progress_updates_by_state_cache[geo_state] = progress_updates.where(geo_state: geo_state)
    end
    return @progress_updates_by_state_cache[geo_state]
  end

  # get the value of this language progress at a particular date (month)
  # if the language isn't in the geo_state provided then it returns 0
  def value_at(geo_state = nil, date = nil)
    date ||= Date.today
    if geo_state
      valid_updates = progress_updates.where(geo_state: geo_state).select{ |u| Date.new(u.year, u.month) <= date }
      valid_updates.empty? ? 0 : valid_updates.max_by{ |u| u.created_at.to_datetime.change(year: u.year, month: u.month) }.progress
    else
      # This gives you the value across the whole language
      # I don't think it's very useful since all updates are by state
      valid_updates = progress_updates.select{ |u| Date.new(u.year, u.month) <= date }
    	valid_updates.empty? ? 0 : valid_updates.max_by{ |u| u.created_at.to_datetime.change(year: u.year, month: u.month) }.progress
    end
  end

  # find the latest progress update in or before a given month
  # and use this to get the score for that month
  def month_score(geo_state, year = Date.today.year, month = Date.today.month)
  	cutoff = Date.new(year, month, -1).end_of_day
    state_updates = progress_updates_geo_state(geo_state).select{ |pu| pu.progress_date <= cutoff }
    # if more than one update shares the same progress_date then max_by will select the first of these
    # we want the one added most recently so we reverse sort by created_at
  	return state_updates.empty? ? 0 : state_updates.sort{ |a,b| b.created_at <=> a.created_at }.max_by(&:progress_date).progress * progress_marker.weight
  end

end

