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

end

