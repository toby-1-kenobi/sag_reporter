class StateLanguage < ActiveRecord::Base

  belongs_to :geo_state
  belongs_to :language
  has_many :language_progresses
  has_many :progress_updates, through: :language_progresses

  validates :geo_state, presence: true
  validates :language, presence: true

end
