class LanguageProgress < ActiveRecord::Base

  # This model corresponds to the outcome progress
  # on a particular progress marker for a particular language in a state.

  belongs_to :state_language
  belongs_to :progress_marker
  has_many :progress_updates, dependent: :destroy
  delegate :status, to: :progress_marker

  validates :progress_marker, presence: true, uniqueness: { scope: :state_language }
  validates :state_language, presence: true

  scope :with_updates, -> { joins :progress_updates }

  def last_updated
  	progress_updates.maximum('created_at')
  end

  # get the value of this language progress at a particular date (month)
  def value_at(date = nil)
    date ||= Date.today
    valid_updates = progress_updates.select{ |u| Date.new(u.year, u.month) <= date }
    valid_updates.empty? ? 0 : valid_updates.sort{ |a,b| b.created_at <=> a.created_at }.max_by(&:progress_date).progress
  end

  # find the latest progress update in or before a given month
  # and use this to get the score for that month
  def month_score(year = Date.today.year, month = Date.today.month)
  	cutoff = Date.new(year, month, -1).end_of_day
    state_updates = progress_updates.select{ |pu| pu.progress_date <= cutoff }
    # if more than one update shares the same progress_date then max_by will select the first of these
    # we want the one added most recently so we reverse sort by created_at
  	return state_updates.empty? ? 0 : state_updates.sort{ |a,b| b.created_at <=> a.created_at }.max_by(&:progress_date).progress * progress_marker.weight
  end

  def outcome_scores(start_date, end_date)
    dates_by_month = (start_date.to_date..end_date.to_date).select{ |d| d.day == 1 }
    pu_iterator = progress_updates.to_a.sort!.each
    scores = Hash.new
    current_value = 0
    dates_by_month.each do |date|
      begin
        while pu_iterator.peek.progress_date <= date.end_of_month.end_of_day
          current_value = pu_iterator.next.progress * progress_marker.weight
        end
      rescue StopIteration
      ensure
        scores[date.strftime("%B %Y")] = current_value
      end
    end
    return scores
  end

end

