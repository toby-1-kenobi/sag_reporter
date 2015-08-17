class LanguageProgress < ActiveRecord::Base

  belongs_to :language
  belongs_to :progress_marker
  has_many :progress_updates, dependent: :destroy

end

